from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

from backend.models.database import get_db, AdviceHistory, generate_uuid
from backend.config.cache import agent_cache
from backend.config.stats import stats

router = APIRouter(prefix="/spoilage", tags=["spoilage"])

FALLBACK_RESPONSE = {
    "remaining_hours": 42.0, "remaining_days": 1.75,
    "risk_level": "medium", "color": "yellow",
    "has_weather_alert": False,
    "explanation": "Your crop has approximately 42 hours of freshness remaining.",
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
    """Check spoilage risk using AI agent (cached)."""
    cache_key = agent_cache.make_key(
        "spoilage", req.crop, req.storage_method, req.hours_since_harvest
    )
    cached = agent_cache.get(cache_key)
    if cached:
        stats.record("spoilage", success=True, cached=True)
        cached["cached"] = True
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
            entry = AdviceHistory(
                id=generate_uuid(), user_id="demo-user",
                type="spoilage", recommendation=result["explanation"][:500],
                savings_rupees=300,
            )
            db.add(entry)
            db.commit()
        except Exception:
            db.rollback()

        response = {"success": True, "data": formatted}
        agent_cache.set(cache_key, response)
        stats.record("spoilage", success=True)
        return response
    except Exception as e:
        print(f"Spoilage endpoint fallback: {e}")
        stats.record("spoilage", success=False)
        return {"success": True, "data": FALLBACK_RESPONSE, "fallback": True}
