from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/spoilage", tags=["spoilage"])


class SpoilageCheckRequest(BaseModel):
    crop: str
    storage_method: str
    hours_since_harvest: float


@router.post("/check")
async def spoilage_check(req: SpoilageCheckRequest):
    """Check spoilage risk (stub with mock data)."""
    return {
        "success": True,
        "data": {
            "remaining_hours": 42.0,
            "remaining_days": 1.75,
            "risk_level": "medium",
            "color": "yellow",
            "has_weather_alert": False,
            "alert_message": None,
            "explanation": (
                f"Your {req.crop} stored via '{req.storage_method}' has "
                f"approximately 42 hours of freshness remaining after "
                f"{req.hours_since_harvest} hours since harvest. Consider "
                f"selling within 24 hours for best quality."
            ),
        },
    }
