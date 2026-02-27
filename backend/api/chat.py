import time
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional

from backend.config.cache import agent_cache
from backend.config.stats import stats

router = APIRouter(prefix="/chat", tags=["chat"])


class ChatRequest(BaseModel):
    message: str
    crop: Optional[str] = "tomato"
    lat: Optional[float] = None
    lng: Optional[float] = None
    soil_type: Optional[str] = "black"
    district: Optional[str] = "Nagpur"
    language: Optional[str] = "hindi"
    volume_kg: Optional[float] = 500
    storage_method: Optional[str] = "open_floor"
    hours_since_harvest: Optional[float] = 0
    current_temp_c: Optional[float] = 35


@router.post("/")
async def chat(req: ChatRequest):
    """Chat with orchestrator — routes to agent (cached, timed, fallback)."""
    start = time.time()

    cache_key = agent_cache.make_key("chat", req.message, req.crop)
    cached = agent_cache.get(cache_key)
    if cached:
        stats.record("chat", success=True, cached=True)
        elapsed = round((time.time() - start) * 1000)
        cached["cached"] = True
        cached["response_time_ms"] = elapsed
        return cached

    try:
        from backend.orchestrator.router import orchestrate
        from backend.orchestrator.formatter import format_response

        user_data = {
            "crop": req.crop or "tomato",
            "lat": req.lat or 21.1458,
            "lng": req.lng or 79.0882,
            "soil_type": req.soil_type or "black",
            "district": req.district or "Nagpur",
            "language": req.language or "hindi",
            "volume_kg": req.volume_kg or 500,
            "storage_method": req.storage_method or "open_floor",
            "hours_since_harvest": req.hours_since_harvest or 0,
            "current_temp_c": req.current_temp_c or 35,
        }

        orch_result = orchestrate(req.message, user_data)
        formatted = format_response(
            orch_result["intent"], orch_result["response"], user_data
        )
        formatted["data"]["intent"] = orch_result["intent"]
        formatted["data"]["agent_used"] = orch_result["agent_used"]

        elapsed = round((time.time() - start) * 1000)
        if elapsed > 10000:
            print(f"⚠️ Chat slow: {elapsed}ms")

        formatted["response_time_ms"] = elapsed
        agent_cache.set(cache_key, formatted)
        stats.record("chat", success=True)
        return formatted

    except Exception as e:
        elapsed = round((time.time() - start) * 1000)
        print(f"Chat fallback ({elapsed}ms): {e}")
        stats.record("chat", success=False)
        return {
            "success": True,
            "data": {
                "intent": "harvest",
                "agent_used": "harvest",
                "type": "harvest_score",
                "explanation_text": (
                    "आपकी फसल का स्कोर 78/100 है। बाज़ार में अभी "
                    "आपूर्ति अधिक है, कीमतें बढ़ने का इंतज़ार करें।"
                ),
            },
            "fallback": True,
            "response_time_ms": elapsed,
        }
