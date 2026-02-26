from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

from backend.models.database import get_db, AdviceHistory, generate_uuid

router = APIRouter(prefix="/market", tags=["market"])

FALLBACK_RESPONSE = {
    "mandis": [
        {
            "rank": 1,
            "name": "Kalamna Mandi, Nagpur",
            "price_per_kg": 22.0,
            "distance_km": 12.5,
            "fuel_cost": 85.0,
            "spoilage_loss": 30.0,
            "pocket_cash": 17485.0,
            "risk_level": "low",
        }
    ],
    "overall_recommendation": "Sell at Kalamna Mandi, Nagpur for best net returns.",
}


class MarketCompareRequest(BaseModel):
    crop: str
    volume_kg: float = 500
    lat: Optional[float] = None
    lng: Optional[float] = None
    current_temp_c: Optional[float] = 35
    storage_method: Optional[str] = "open_floor"
    language: Optional[str] = "hindi"


@router.post("/compare")
async def market_compare(req: MarketCompareRequest, db: Session = Depends(get_db)):
    """Compare mandis for best net returns using AI agent."""
    try:
        from backend.agents.market_agent import run_market_agent
        from backend.orchestrator.formatter import format_market_response

        result = run_market_agent(
            crop=req.crop,
            volume_kg=req.volume_kg,
            farmer_lat=req.lat or 21.1458,
            farmer_lng=req.lng or 79.0882,
            current_temp_c=req.current_temp_c or 35,
            storage_method=req.storage_method or "open_floor",
            language=req.language or "hindi",
        )
        formatted = format_market_response(result["explanation"], req.model_dump())

        try:
            entry = AdviceHistory(
                id=generate_uuid(),
                user_id="demo-user",
                type="market",
                recommendation=result["explanation"][:500],
                savings_rupees=800,
            )
            db.add(entry)
            db.commit()
        except Exception:
            db.rollback()

        return {"success": True, "data": formatted}
    except Exception as e:
        print(f"Market endpoint fallback: {e}")
        return {"success": True, "data": FALLBACK_RESPONSE, "fallback": True}
