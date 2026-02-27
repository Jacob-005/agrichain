import time
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

from backend.models.database import get_db, AdviceHistory, generate_uuid
from backend.config.cache import agent_cache
from backend.config.stats import stats

router = APIRouter(prefix="/harvest", tags=["harvest"])

FALLBACK_DATA = {
    "type": "harvest_score",
    "score": 75,
    "color": "yellow",
    "action": "wait",
    "explanation_text": (
        "मौसम और बाज़ार की स्थिति के आधार पर, 1-2 दिन इंतज़ार करने "
        "की सलाह है। नागपुर मंडी में आपूर्ति अधिक है, शुक्रवार तक "
        "कीमतें ₹2/किलो बढ़ सकती हैं।"
    ),
    "show_voice_button": True,
}


class HarvestScoreRequest(BaseModel):
    crop: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    soil_type: Optional[str] = None
    district: Optional[str] = None
    language: Optional[str] = "hindi"


@router.post("/score")
async def harvest_score(req: HarvestScoreRequest, db: Session = Depends(get_db)):
    """Calculate harvest score using AI agent (cached, timed, with fallback)."""
    start = time.time()

    # Check cache
    cache_key = agent_cache.make_key("harvest", req.crop, req.lat, req.soil_type)
    cached = agent_cache.get(cache_key)
    if cached:
        stats.record("harvest", success=True, cached=True)
        elapsed = round((time.time() - start) * 1000)
        cached["cached"] = True
        cached["response_time_ms"] = elapsed
        return cached

    try:
        from backend.agents.harvest_agent import run_harvest_agent
        from backend.orchestrator.formatter import format_harvest_response

        result = run_harvest_agent(
            crop=req.crop,
            lat=req.lat or 21.1458,
            lng=req.lng or 79.0882,
            soil_type=req.soil_type or "black",
            district=req.district or "Nagpur",
            language=req.language or "hindi",
        )
        formatted = format_harvest_response(result["explanation"], req.model_dump())

        try:
            db.add(AdviceHistory(
                id=generate_uuid(), user_id="demo-user",
                type="harvest", recommendation=result["explanation"][:500],
                savings_rupees=500,
            ))
            db.commit()
        except Exception:
            db.rollback()

        elapsed = round((time.time() - start) * 1000)
        if elapsed > 10000:
            print(f"⚠️ Harvest slow: {elapsed}ms")

        response = {"success": True, "data": formatted, "response_time_ms": elapsed}
        agent_cache.set(cache_key, response)
        stats.record("harvest", success=True)
        return response

    except Exception as e:
        elapsed = round((time.time() - start) * 1000)
        print(f"Harvest fallback ({elapsed}ms): {e}")
        stats.record("harvest", success=False)
        return {
            "success": True, "data": FALLBACK_DATA,
            "fallback": True, "response_time_ms": elapsed,
        }
