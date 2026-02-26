from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/market", tags=["market"])


class MarketCompareRequest(BaseModel):
    crop: str
    volume_kg: float


@router.post("/compare")
async def market_compare(req: MarketCompareRequest):
    """Compare mandis for best net returns (stub with mock data).

    Note: Rank 1 (Kalamna) has the highest pocket_cash but NOT the highest
    price_per_kg — demonstrating the core value prop of AgriChain.
    """
    return {
        "success": True,
        "data": {
            "mandis": [
                {
                    "rank": 1,
                    "name": "Kalamna Mandi, Nagpur",
                    "price_per_kg": 22.0,
                    "distance_km": 12.5,
                    "fuel_cost": 85.0,
                    "spoilage_loss": 30.0,
                    "spoilage_pct": 1.2,
                    "pocket_cash": round(req.volume_kg * 22.0 - 85.0 - 30.0, 2),
                    "risk_level": "low",
                    "explanation": (
                        "Closest mandi with good demand. Low spoilage risk "
                        "due to short travel. Best net returns despite "
                        "slightly lower price."
                    ),
                },
                {
                    "rank": 2,
                    "name": "Pulgaon Mandi",
                    "price_per_kg": 25.0,
                    "distance_km": 68.0,
                    "fuel_cost": 320.0,
                    "spoilage_loss": 180.0,
                    "spoilage_pct": 4.5,
                    "pocket_cash": round(req.volume_kg * 25.0 - 320.0 - 180.0, 2),
                    "risk_level": "medium",
                    "explanation": (
                        "Higher price but longer distance increases fuel "
                        "and spoilage costs. Medium risk considering "
                        "current weather."
                    ),
                },
                {
                    "rank": 3,
                    "name": "Hinganghat Mandi",
                    "price_per_kg": 28.0,
                    "distance_km": 95.0,
                    "fuel_cost": 480.0,
                    "spoilage_loss": 350.0,
                    "spoilage_pct": 8.2,
                    "pocket_cash": round(req.volume_kg * 28.0 - 480.0 - 350.0, 2),
                    "risk_level": "high",
                    "explanation": (
                        "Highest price but very far. High spoilage risk "
                        "in current heat. Fuel costs eat into profit. "
                        "Not recommended unless you have refrigerated transport."
                    ),
                },
            ],
            "overall_recommendation": (
                "Sell at Kalamna Mandi, Nagpur. Despite lower per-kg price, "
                "you save ₹235 on fuel and ₹150 on spoilage compared to "
                "Pulgaon. Net gain is highest at Kalamna."
            ),
        },
    }
