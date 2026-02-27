import time
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

from backend.models.database import get_db, AdviceHistory, generate_uuid
from backend.config.cache import agent_cache
from backend.config.stats import stats

router = APIRouter(prefix="/preservation", tags=["preservation"])

FALLBACK_DATA = {
    "type": "preservation_list",
    "explanation_text": (
        "🧊 भंडारण सुझाव:\n\n"
        "1️⃣ गीली जूट बैग (मुफ़्त) — 2 दिन अतिरिक्त ताज़गी\n"
        "   बोरी को गीला करें, छाया में रखें, हर 6 घंटे गीला करें\n\n"
        "2️⃣ हवादार प्लास्टिक क्रेट (₹150) — 4 दिन अतिरिक्त\n"
        "   ₹1,200 तक बचत, 3 बार उपयोग में खर्च वसूल\n\n"
        "3️⃣ कोल्ड स्टोरेज (₹500) — 10 दिन अतिरिक्त\n"
        "   ₹3,500 तक बचत, 100 किलो से अधिक के लिए उपयुक्त"
    ),
    "show_voice_button": True,
}


class PreservationOptionsRequest(BaseModel):
    crop: str
    current_storage: str = "open_floor"
    temp_c: Optional[float] = 35
    language: Optional[str] = "hindi"


@router.post("/options")
async def preservation_options(
    req: PreservationOptionsRequest, db: Session = Depends(get_db)
):
    """Get preservation options using AI agent (cached, timed, with fallback)."""
    start = time.time()

    cache_key = agent_cache.make_key("preservation", req.crop, req.current_storage)
    cached = agent_cache.get(cache_key)
    if cached:
        stats.record("preservation", success=True, cached=True)
        elapsed = round((time.time() - start) * 1000)
        cached["cached"] = True
        cached["response_time_ms"] = elapsed
        return cached

    try:
        from backend.agents.preservation_agent import run_preservation_agent
        from backend.orchestrator.formatter import format_preservation_response

        result = run_preservation_agent(
            crop=req.crop, current_storage=req.current_storage,
            temp_c=req.temp_c or 35, language=req.language or "hindi",
        )
        formatted = format_preservation_response(
            result["explanation"], req.model_dump()
        )

        try:
            db.add(AdviceHistory(
                id=generate_uuid(), user_id="demo-user",
                type="preservation", recommendation=result["explanation"][:500],
                savings_rupees=500,
            ))
            db.commit()
        except Exception:
            db.rollback()

        elapsed = round((time.time() - start) * 1000)
        if elapsed > 10000:
            print(f"⚠️ Preservation slow: {elapsed}ms")

        response = {"success": True, "data": formatted, "response_time_ms": elapsed}
        agent_cache.set(cache_key, response)
        stats.record("preservation", success=True)
        return response

    except Exception as e:
        elapsed = round((time.time() - start) * 1000)
        print(f"Preservation fallback ({elapsed}ms): {e}")
        stats.record("preservation", success=False)

        # Direct tool fallback
        try:
            from backend.tools.preservation import get_preservation_options
            methods = get_preservation_options(req.crop, req.current_storage)
            text_parts = ["🧊 भंडारण सुझाव:\n"]
            for i, m in enumerate(methods[:3], 1):
                text_parts.append(
                    f"{i}️⃣ {m.get('name_hi', m.get('name', ''))} "
                    f"(₹{m.get('cost_rupees', 0)}) — "
                    f"{m.get('extra_days', 0)} दिन अतिरिक्त"
                )
            return {
                "success": True,
                "data": {
                    "type": "preservation_list",
                    "explanation_text": "\n".join(text_parts),
                    "crop": req.crop,
                    "show_voice_button": True,
                },
                "fallback": True, "response_time_ms": elapsed,
            }
        except Exception:
            return {
                "success": True, "data": FALLBACK_DATA,
                "fallback": True, "response_time_ms": elapsed,
            }
