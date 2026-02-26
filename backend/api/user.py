from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/user", tags=["user"])


class ProfileCreateRequest(BaseModel):
    name: str
    age: int
    lat: float
    lng: float
    district: str
    soil_type: str
    language: str = "hindi"


class ProfileUpdateRequest(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    district: Optional[str] = None
    soil_type: Optional[str] = None
    language: Optional[str] = None


class UserCropsRequest(BaseModel):
    crop_ids: list[str]


@router.post("/profile")
async def create_profile(req: ProfileCreateRequest):
    """Create user profile (stub)."""
    return {"success": True, "user_id": "demo-user-001"}


@router.get("/profile")
async def get_profile():
    """Get user profile (stub with mock data)."""
    return {
        "success": True,
        "data": {
            "name": "Ramesh",
            "age": 45,
            "lat": 21.1458,
            "lng": 79.0882,
            "district": "Nagpur",
            "soil_type": "black",
            "language": "hindi",
            "crops": [{"id": "tomato", "name": "Tomato"}],
        },
    }


@router.put("/profile")
async def update_profile(req: ProfileUpdateRequest):
    """Update user profile (stub)."""
    return {"success": True}


@router.post("/crops")
async def set_user_crops(req: UserCropsRequest):
    """Set user crops (stub)."""
    return {"success": True}
