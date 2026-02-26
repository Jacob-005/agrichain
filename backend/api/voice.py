"""
voice.py — TTS endpoint for voice explanations using gTTS.

Generates Hindi (and other Indian language) audio from text
for the mobile app's voice buttons.
"""

import os
import uuid

from fastapi import APIRouter
from fastapi.responses import FileResponse
from pydantic import BaseModel

router = APIRouter(prefix="/voice", tags=["voice"])

AUDIO_DIR = os.path.join(os.path.dirname(__file__), "..", "temp_audio")
os.makedirs(AUDIO_DIR, exist_ok=True)

LANG_MAP = {
    "hindi": "hi",
    "marathi": "mr",
    "bengali": "bn",
    "gujarati": "gu",
    "punjabi": "pa",
    "telugu": "te",
    "urdu": "ur",
    "english": "en",
    "tamil": "ta",
    "kannada": "kn",
    "malayalam": "ml",
}


class VoiceRequest(BaseModel):
    text: str
    language: str = "hindi"


@router.post("/generate")
async def generate_voice(body: VoiceRequest):
    """Generate audio from text using gTTS."""
    try:
        from gtts import gTTS

        lang_code = LANG_MAP.get(body.language.lower(), "hi")
        filename = f"{uuid.uuid4().hex}.mp3"
        filepath = os.path.join(AUDIO_DIR, filename)

        tts = gTTS(text=body.text, lang=lang_code)
        tts.save(filepath)

        return {
            "success": True,
            "audio_url": f"/api/v1/voice/file/{filename}",
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


@router.get("/file/{filename}")
async def get_audio_file(filename: str):
    """Serve a generated audio file."""
    filepath = os.path.join(AUDIO_DIR, filename)
    if os.path.exists(filepath):
        return FileResponse(filepath, media_type="audio/mpeg")
    return {"success": False, "error": "File not found"}
