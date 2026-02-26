"""
spoilage_agent.py — AI agent for crop spoilage prediction.

Checks remaining shelf life using weather-aware calculations
and alerts on heatwave risks.
"""

import os
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.prebuilt import create_react_agent
from langchain_core.tools import tool

from backend.tools.spoilage import check_spoilage_with_weather
from backend.tools.weather import detect_heatwave_risk
from backend.tools.explanation import generate_explanation_safe


# ─── Tool Wrappers ────────────────────────────────────────────

@tool
def check_crop_spoilage(
    crop: str,
    storage_method: str,
    hours_since_harvest: float,
    lat: float,
    lng: float,
) -> dict:
    """Check how many hours a crop will stay fresh based on
    storage method, time since harvest, and live weather at
    the location. Returns remaining_hours, risk_level
    (low/medium/high), color (green/yellow/red), and
    spoilage percentage."""
    return check_spoilage_with_weather(
        crop, storage_method, hours_since_harvest, lat, lng
    )


@tool
def check_heatwave(lat: float, lng: float) -> dict:
    """Check if a heatwave is expected in the next 24 hours.
    Returns alert status (true/false) and projected max
    temperature. Important for spoilage acceleration."""
    return detect_heatwave_risk(lat, lng)


# ─── System Prompt ────────────────────────────────────────────

SPOILAGE_SYSTEM_PROMPT = """You are AgriChain's Spoilage Timer Agent for Indian farmers.

YOUR PROCESS — follow these steps IN ORDER:
1. Call check_crop_spoilage with the farmer's crop details and location
2. Call check_heatwave to see if temperatures will rise soon
3. Based on the risk level in the result, respond with the appropriate urgency level
4. STOP after giving your answer.

URGENCY LEVELS — match your tone to the risk:
- GREEN (remaining > 48 hours): Calm and reassuring. "Your crop is safe for now. You have about X days."
- YELLOW (remaining 12-48 hours): Concerned but not panicked. "You should act within the next X hours. Consider selling or improving your storage."
- RED (remaining < 12 hours): URGENT and direct. "⚠️ Your crop needs immediate attention! Only X hours left. Sell today or improve storage RIGHT NOW."

RULES:
- ALWAYS state the exact number of hours AND days remaining
- If a heatwave is coming, warn that spoilage will accelerate
- ALWAYS suggest one specific next action the farmer should take
- For RED situations: use ⚠️ emoji and recommend selling TODAY
- Mention the current temperature and storage method
- Keep response under 100 words
- Respond in the language requested"""


# ─── Agent Singleton ──────────────────────────────────────────

_spoilage_agent = None


def get_spoilage_agent():
    global _spoilage_agent
    if _spoilage_agent is None:
        llm = ChatGoogleGenerativeAI(
            model="gemini-2.0-flash",
            temperature=0.3,
            google_api_key=os.getenv("GOOGLE_API_KEY", ""),
        )
        _spoilage_agent = create_react_agent(
            llm,
            [check_crop_spoilage, check_heatwave],
            prompt=SPOILAGE_SYSTEM_PROMPT,
        )
    return _spoilage_agent


# ─── Public Run Function ─────────────────────────────────────

def run_spoilage_agent(
    crop: str,
    storage_method: str,
    hours_since_harvest: float,
    lat: float,
    lng: float,
    language: str = "hindi",
) -> dict:
    try:
        agent = get_spoilage_agent()
        user_msg = (
            f"The farmer harvested {crop} about "
            f"{hours_since_harvest} hours ago. "
            f"Storage: {storage_method}. "
            f"Location: lat={lat}, lng={lng}. "
            f"How long will it stay fresh? Respond in {language}."
        )
        result = agent.invoke(
            {"messages": [{"role": "user", "content": user_msg}]},
            config={"recursion_limit": 8},
        )
        return {
            "explanation": result["messages"][-1].content,
            "success": True,
        }
    except Exception as e:
        print(f"Spoilage agent error: {e}")
        fallback = generate_explanation_safe(
            {"crop": crop, "remaining_hours": 24}, language, "spoilage"
        )
        return {"explanation": fallback, "success": False, "error": str(e)}


if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv()
    print("Testing spoilage agent...")
    result = run_spoilage_agent(
        "tomato", "open_floor", 6, 21.1458, 79.0882, "hindi"
    )
    print(f"Success: {result['success']}")
    print(f"Explanation: {result['explanation'][:500]}")
