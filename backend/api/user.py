from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

import jwt
import os

from backend.config.settings import settings
from backend.models.database import get_db, User, UserCrop

router = APIRouter(prefix="/user", tags=["user"])


# ─── Auth Dependency ──────────────────────────────────────────

async def get_current_user(
    authorization: str = Header(None),
    db: Session = Depends(get_db),
):
    """Extract and verify JWT, return the User from DB."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(401, "Missing or invalid token")

    token = authorization.replace("Bearer ", "")
    try:
        payload = jwt.decode(
            token, settings.JWT_SECRET, algorithms=["HS256"]
        )
        user_id = payload.get("user_id")
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(401, "User not found")
        return user
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(401, "Invalid token")


# ─── Models ───────────────────────────────────────────────────

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


# ─── Endpoints ────────────────────────────────────────────────

@router.post("/profile")
async def create_profile(
    req: ProfileCreateRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create/update user profile in DB."""
    user.name = req.name
    user.age = req.age
    user.lat = req.lat
    user.lng = req.lng
    user.district = req.district
    user.soil_type = req.soil_type
    user.language = req.language
    db.commit()
    return {"success": True, "user_id": user.id}


@router.get("/profile")
async def get_profile(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get user profile from DB."""
    crops = db.query(UserCrop).filter(UserCrop.user_id == user.id).all()
    return {
        "success": True,
        "data": {
            "user_id": user.id,
            "name": user.name,
            "age": user.age,
            "lat": user.lat,
            "lng": user.lng,
            "district": user.district,
            "soil_type": user.soil_type,
            "language": user.language,
            "crops": [{"id": c.crop_id, "status": c.status} for c in crops],
        },
    }


@router.put("/profile")
async def update_profile(
    req: ProfileUpdateRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Partial update of user profile."""
    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(user, field, value)
    db.commit()
    return {"success": True}


@router.post("/crops")
async def set_user_crops(
    req: UserCropsRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Set user crops — replaces existing list."""
    # Remove old crops
    db.query(UserCrop).filter(UserCrop.user_id == user.id).delete()

    # Add new ones
    for crop_id in req.crop_ids:
        db.add(UserCrop(user_id=user.id, crop_id=crop_id, status="growing"))

    db.commit()
    return {"success": True, "crops": req.crop_ids}
