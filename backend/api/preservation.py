from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/preservation", tags=["preservation"])


class PreservationOptionsRequest(BaseModel):
    crop: str
    current_storage: str


@router.post("/options")
async def preservation_options(req: PreservationOptionsRequest):
    """Get preservation method options (stub with mock data)."""
    return {
        "success": True,
        "data": {
            "methods": [
                {
                    "level": 1,
                    "name": "Wet Jute Bag Cover",
                    "cost_rupees": 20.0,
                    "extra_days": 2,
                    "saves_rupees": 500.0,
                    "instructions": (
                        "Wrap produce in damp jute bags. Keep in shade. "
                        "Re-wet every 6 hours. Works best for leafy "
                        "vegetables and tomatoes."
                    ),
                    "explanation": (
                        "Cheapest option. Evaporative cooling extends "
                        "freshness by ~2 days. Suitable for small batches."
                    ),
                },
                {
                    "level": 2,
                    "name": "Ventilated Plastic Crates",
                    "cost_rupees": 150.0,
                    "extra_days": 4,
                    "saves_rupees": 1200.0,
                    "instructions": (
                        "Place produce in ventilated plastic crates. "
                        "Stack max 3 high. Store in shade with airflow. "
                        "Do not mix different crops."
                    ),
                    "explanation": (
                        "Moderate cost. Reduces bruising and compression "
                        "damage by 60%. Reusable crates pay for themselves "
                        "in 3 uses."
                    ),
                },
                {
                    "level": 3,
                    "name": "CoolBot Cooling Chamber",
                    "cost_rupees": 500.0,
                    "extra_days": 10,
                    "saves_rupees": 3500.0,
                    "instructions": (
                        "Transport to nearest CoolBot facility or use "
                        "community cold storage. Maintain 4°C for "
                        "tomatoes, 10°C for bananas. Pre-cool before "
                        "storing."
                    ),
                    "explanation": (
                        "Highest cost but biggest savings. Community "
                        "cold storage shared costs make this viable for "
                        f"batches over 100 kg of {req.crop}."
                    ),
                },
            ]
        },
    }
