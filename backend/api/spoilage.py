import time
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

from backend.models.database import get_db, AdviceHistory, generate_uuid
from backend.config.cache import agent_cache
from backend.config.stats import stats

router = APIRouter(prefix="/spoilage", tags=["spoilage"])

FALLBACK_DATA = {
    "type": "spoilage_timer",
    "remaining_hours": 42.0,
    "remaining_days": 1.8,
    "color": "yellow",
    "urgency": "attention",
    "has_weather_alert": False,
    "vibrate_phone": False,
    "explanation_text": (
        "आपकी फसल लगभग 42 घंटे (1.8 दिन) तक ताज़ा रहेगी। "
        "24 घंटे के भीतर बेचने या भंडारण सुधारने पर विचार करें।"
    ),
    "show_voice_button": True,
}


class SpoilageCheckRequest(BaseModel):
    crop: str
    storage_method: str = "open_floor"
    hours_since_harvest: float = 0
    lat: Optional[float] = None
    lng: Optional[float] = None
    language: Optional[str] = "hindi"


@router.post("/check")
async def spoilage_check(req: SpoilageCheckRequest, db: Session = Depends(get_db)):
    """Check spoilage using AI agent (cached, timed, with fallback)."""
    start = time.time()

    cache_key = agent_cache.make_key(
        "spoilage", req.crop, req.storage_method, req.hours_since_harvest
    )
    cached = agent_cache.get(cache_key)
    if cached:
        stats.record("spoilage", success=True, cached=True)
        elapsed = round((time.time() - start) * 1000)
        cached["cached"] = True
        cached["response_time_ms"] = elapsed
        return cached

    try:
        from backend.agents.spoilage_agent import run_spoilage_agent
        from backend.orchestrator.formatter import format_spoilage_response

        result = run_spoilage_agent(
            crop=req.crop, storage_method=req.storage_method,
            hours_since_harvest=req.hours_since_harvest,
            lat=req.lat or 21.1458, lng=req.lng or 79.0882,
            language=req.language or "hindi",
        )
        formatted = format_spoilage_response(result["explanation"], req.model_dump())

        try:
            db.add(AdviceHistory(
                id=generate_uuid(), user_id="demo-user",
                type="spoilage", recommendation=result["explanation"][:500],
                savings_rupees=300,
            ))
            db.commit()
        except Exception:
            db.rollback()

        elapsed = round((time.time() - start) * 1000)
        if elapsed > 10000:
            print(f"⚠️ Spoilage slow: {elapsed}ms")

        response = {"success": True, "data": formatted, "response_time_ms": elapsed}
        agent_cache.set(cache_key, response)
        stats.record("spoilage", success=True)
        return response

    except Exception as e:
        elapsed = round((time.time() - start) * 1000)
        print(f"Spoilage fallback ({elapsed}ms): {e}")
        stats.record("spoilage", success=False)

        # Direct tool fallback: bypass agent, call tool directly
        try:
            from backend.tools.spoilage import predict_remaining_hours
            direct = predict_remaining_hours(req.crop, req.storage_method, 35)
            remaining = max(0, direct.get("remaining_hours", 42) - req.hours_since_harvest)
            if remaining > 48:
                color, urgency = "green", "safe"
            elif remaining > 12:
                color, urgency = "yellow", "attention"
            else:
                color, urgency = "red", "urgent"
            return {
                "success": True,
                "data": {
                    "type": "spoilage_timer",
                    "remaining_hours": round(remaining, 1),
                    "remaining_days": round(remaining / 24, 1),
                    "color": color, "urgency": urgency,
                    "has_weather_alert": False, "vibrate_phone": color == "red",
                    "explanation_text": f"आपकी {req.crop} लगभग {round(remaining)} घंटे ताज़ा रहेगी।",
                    "show_voice_button": True,
                },
                "fallback": True, "response_time_ms": elapsed,
            }
        except Exception:
            return {
                "success": True, "data": FALLBACK_DATA,
                "fallback": True, "response_time_ms": elapsed,
            }
