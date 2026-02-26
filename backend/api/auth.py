import uuid
from datetime import datetime, timedelta

import jwt
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from backend.config.settings import settings

router = APIRouter(prefix="/auth", tags=["auth"])


class SendOTPRequest(BaseModel):
    phone: str


class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str


@router.post("/send-otp")
async def send_otp(req: SendOTPRequest):
    """Send OTP to phone number (mock implementation)."""
    return {"success": True, "message": f"OTP sent to {req.phone}"}


@router.post("/verify-otp")
async def verify_otp(req: VerifyOTPRequest):
    """Verify OTP and return JWT token (mock: accepts '123456')."""
    if req.otp != "123456":
        raise HTTPException(status_code=401, detail="Invalid OTP")

    user_id = str(uuid.uuid4())
    token = jwt.encode(
        {
            "phone": req.phone,
            "user_id": user_id,
            "exp": datetime.utcnow() + timedelta(days=30),
        },
        settings.JWT_SECRET,
        algorithm="HS256",
    )
    return {"success": True, "token": token, "is_new_user": True}
