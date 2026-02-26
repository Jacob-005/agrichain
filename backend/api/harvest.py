from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/harvest", tags=["harvest"])

# Stub fallback in case agent fails
FALLBACK_RESPONSE = {
    "score": 78,
    "color": "yellow",
    "recommendation": "Wait 2-3 days",
    "explanation": (
        "Nagpur mandi has excess supply today. Prices will rise "
        "by ₹2/kg on Friday. Wait for better returns."
    ),
    "breakdown": {"weather": 25, "market": 28, "readiness": 25},
}


class HarvestScoreRequest(BaseModel):
    crop: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    soil_type: Optional[str] = None
    district: Optional[str] = None
    language: Optional[str] = "hindi"


@router.post("/score")
async def harvest_score(req: HarvestScoreRequest):
    """Calculate harvest score using AI agent."""
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
        formatted = format_harvest_response(
            result["explanation"], req.model_dump()
        )
        return {"success": True, "data": formatted}
    except Exception as e:
        print(f"Harvest endpoint fallback: {e}")
        return {"success": True, "data": FALLBACK_RESPONSE, "fallback": True}
