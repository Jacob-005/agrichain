from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/harvest", tags=["harvest"])


class HarvestScoreRequest(BaseModel):
    crop: str


@router.post("/score")
async def harvest_score(req: HarvestScoreRequest):
    """Calculate harvest score (stub with mock data)."""
    return {
        "success": True,
        "data": {
            "score": 78,
            "color": "yellow",
            "recommendation": "Wait 2-3 days",
            "explanation": (
                "Nagpur mandi has excess supply today. Prices will rise "
                "by ₹2/kg on Friday. Wait for better returns."
            ),
            "breakdown": {"weather": 25, "market": 28, "readiness": 25},
        },
    }
