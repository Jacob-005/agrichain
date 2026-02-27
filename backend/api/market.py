import time
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

from backend.models.database import get_db, AdviceHistory, generate_uuid
from backend.config.cache import agent_cache
from backend.config.stats import stats

router = APIRouter(prefix="/market", tags=["market"])

FALLBACK_DATA = {
    "type": "market_comparison",
    "explanation_text": (
        "📊 मंडी तुलना:\n\n"
        "1️⃣ कलामना मंडी, नागपुर — ₹22/किलो, दूरी 12 किमी\n"
        "   ईंधन: ₹85 | खराबी: ₹30 | 💰 पॉकेट कैश: ₹17,485\n\n"
        "2️⃣ पुलगांव मंडी — ₹25/किलो, दूरी 68 किमी\n"
        "   ईंधन: ₹320 | खराबी: ₹180 | 💰 पॉकेट कैश: ₹19,500\n\n"
        "3️⃣ हिंगणघाट मंडी — ₹28/किलो, दूरी 95 किमी\n"
        "   ईंधन: ₹480 | खराबी: ₹350 | 💰 पॉकेट कैश: ₹21,570\n\n"
        "✅ कलामना मंडी सबसे नज़दीक है — कम ईंधन, कम खराबी।"
    ),
    "crop": "tomato",
    "show_voice_button": True,
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
    """Compare mandis using AI agent (cached, timed, with fallback)."""
    start = time.time()

    cache_key = agent_cache.make_key("market", req.crop, req.volume_kg, req.lat)
    cached = agent_cache.get(cache_key)
    if cached:
        stats.record("market", success=True, cached=True)
        elapsed = round((time.time() - start) * 1000)
        cached["cached"] = True
        cached["response_time_ms"] = elapsed
        return cached

    try:
        from backend.agents.market_agent import run_market_agent
        from backend.orchestrator.formatter import format_market_response

        result = run_market_agent(
            crop=req.crop, volume_kg=req.volume_kg,
            farmer_lat=req.lat or 21.1458, farmer_lng=req.lng or 79.0882,
            current_temp_c=req.current_temp_c or 35,
            storage_method=req.storage_method or "open_floor",
            language=req.language or "hindi",
        )
        formatted = format_market_response(result["explanation"], req.model_dump())

        try:
            db.add(AdviceHistory(
                id=generate_uuid(), user_id="demo-user",
                type="market", recommendation=result["explanation"][:500],
                savings_rupees=800,
            ))
            db.commit()
        except Exception:
            db.rollback()

        elapsed = round((time.time() - start) * 1000)
        if elapsed > 10000:
            print(f"⚠️ Market slow: {elapsed}ms")

        response = {"success": True, "data": formatted, "response_time_ms": elapsed}
        agent_cache.set(cache_key, response)
        stats.record("market", success=True)
        return response

    except Exception as e:
        elapsed = round((time.time() - start) * 1000)
        print(f"Market fallback ({elapsed}ms): {e}")
        stats.record("market", success=False)
        fallback = {**FALLBACK_DATA, "volume_kg": req.volume_kg, "crop": req.crop}
        return {
            "success": True, "data": fallback,
            "fallback": True, "response_time_ms": elapsed,
        }
