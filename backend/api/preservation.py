from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/preservation", tags=["preservation"])

# Stub fallback
FALLBACK_RESPONSE = {
    "methods": [
        {
            "level": 1,
            "name": "Wet Jute Bag Cover",
            "cost_rupees": 20.0,
            "extra_days": 2,
            "saves_rupees": 500.0,
            "instructions": "Wrap produce in damp jute bags. Keep in shade.",
        }
    ]
}


class PreservationOptionsRequest(BaseModel):
    crop: str
    current_storage: str = "open_floor"
    temp_c: Optional[float] = 35
    language: Optional[str] = "hindi"


@router.post("/options")
async def preservation_options(req: PreservationOptionsRequest):
    """Get preservation method options using AI agent."""
    try:
        from backend.agents.preservation_agent import run_preservation_agent
        from backend.orchestrator.formatter import format_preservation_response

        result = run_preservation_agent(
            crop=req.crop,
            current_storage=req.current_storage,
            temp_c=req.temp_c or 35,
            language=req.language or "hindi",
        )
        formatted = format_preservation_response(
            result["explanation"], req.model_dump()
        )
        return {"success": True, "data": formatted}
    except Exception as e:
        print(f"Preservation endpoint fallback: {e}")
        return {"success": True, "data": FALLBACK_RESPONSE, "fallback": True}
