from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional

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
    """Chat with AgriChain orchestrator — routes to appropriate agent."""
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
        return formatted
    except Exception as e:
        print(f"Chat endpoint error: {e}")
        return {
            "success": True,
            "data": {
                "intent": "harvest",
                "response": (
                    "Your harvest score is 78 out of 100. The market "
                    "conditions suggest waiting 2-3 days for better prices."
                ),
                "structured_data": None,
            },
            "fallback": True,
        }
