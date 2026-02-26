import os
from datetime import datetime, timedelta

import jwt
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from backend.config.settings import settings
from backend.models.database import get_db, User, generate_uuid

router = APIRouter(prefix="/auth", tags=["auth"])

# In-memory OTP store (for demo; production would use Redis/SMS)
_otp_store = {}


class SendOTPRequest(BaseModel):
    phone: str


class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str


@router.post("/send-otp")
async def send_otp(req: SendOTPRequest):
    """Send OTP to phone number. Demo always uses 123456."""
    _otp_store[req.phone] = "123456"
    return {"success": True, "message": f"OTP sent to {req.phone}"}


@router.post("/verify-otp")
async def verify_otp(req: VerifyOTPRequest, db: Session = Depends(get_db)):
    """Verify OTP and return JWT token. Creates user if new."""
    # Accept stored OTP or always-valid 123456 for demo
    stored_otp = _otp_store.get(req.phone, "123456")
    if req.otp != stored_otp and req.otp != "123456":
        raise HTTPException(status_code=401, detail="Invalid OTP")

    # Check if user exists in DB
    user = db.query(User).filter(User.phone == req.phone).first()
    is_new_user = user is None

    if is_new_user:
        user = User(id=generate_uuid(), phone=req.phone)
        db.add(user)
        db.commit()
        db.refresh(user)

    # Generate JWT
    token = jwt.encode(
        {
            "phone": req.phone,
            "user_id": user.id,
            "exp": datetime.utcnow() + timedelta(days=30),
        },
        settings.JWT_SECRET,
        algorithm="HS256",
    )

    # Clean up OTP
    _otp_store.pop(req.phone, None)

    return {
        "success": True,
        "token": token,
        "is_new_user": is_new_user,
        "user_id": user.id,
    }
