from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

from backend.models.database import get_db, AdviceHistory, generate_uuid

router = APIRouter(prefix="/preservation", tags=["preservation"])

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
async def preservation_options(req: PreservationOptionsRequest, db: Session = Depends(get_db)):
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
        formatted = format_preservation_response(result["explanation"], req.model_dump())

        try:
            entry = AdviceHistory(
                id=generate_uuid(),
                user_id="demo-user",
                type="preservation",
                recommendation=result["explanation"][:500],
                savings_rupees=500,
            )
            db.add(entry)
            db.commit()
        except Exception:
            db.rollback()

        return {"success": True, "data": formatted}
    except Exception as e:
        print(f"Preservation endpoint fallback: {e}")
        return {"success": True, "data": FALLBACK_RESPONSE, "fallback": True}
