from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/spoilage", tags=["spoilage"])

# Stub fallback
FALLBACK_RESPONSE = {
    "remaining_hours": 42.0,
    "remaining_days": 1.75,
    "risk_level": "medium",
    "color": "yellow",
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
async def spoilage_check(req: SpoilageCheckRequest):
    """Check spoilage risk using AI agent."""
    try:
        from backend.agents.spoilage_agent import run_spoilage_agent
        from backend.orchestrator.formatter import format_spoilage_response

        result = run_spoilage_agent(
            crop=req.crop,
            storage_method=req.storage_method,
            hours_since_harvest=req.hours_since_harvest,
            lat=req.lat or 21.1458,
            lng=req.lng or 79.0882,
            language=req.language or "hindi",
        )
        formatted = format_spoilage_response(
            result["explanation"], req.model_dump()
        )
        return {"success": True, "data": formatted}
    except Exception as e:
        print(f"Spoilage endpoint fallback: {e}")
        return {"success": True, "data": FALLBACK_RESPONSE, "fallback": True}
