from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/chat", tags=["chat"])


class ChatRequest(BaseModel):
    message: str


@router.post("/")
async def chat(req: ChatRequest):
    """Chat with AgriChain orchestrator (stub)."""
    return {
        "success": True,
        "data": {
            "intent": "harvest",
            "response": (
                "Your harvest score is 78 out of 100. The market conditions "
                "suggest waiting 2-3 days for better prices. Nagpur mandi "
                "has excess supply today, but prices are expected to rise "
                "by ₹2/kg by Friday."
            ),
            "structured_data": None,
        },
    }
