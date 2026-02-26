"""
preservation_agent.py — AI agent for preservation method recommendations.

Recommends cost-effective preservation methods sorted by ROI,
with free methods always presented first.
"""

import os
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.prebuilt import create_react_agent
from langchain_core.tools import tool

from backend.tools.preservation import (
    get_preservation_options,
    calculate_preservation_benefit,
)
from backend.tools.spoilage import predict_remaining_hours
from backend.tools.explanation import generate_explanation_safe


# ─── Tool Wrappers ────────────────────────────────────────────

@tool
def fetch_preservation_options(crop: str, current_storage: str) -> list:
    """Get available preservation methods for a crop, excluding
    the method the farmer already uses. Returns methods sorted
    by ROI (free methods first, then best value). Each method
    has: name, cost_rupees, saves_rupees, instructions."""
    return get_preservation_options(crop, current_storage)


@tool
def calculate_benefit(
    crop: str, method_id: str, current_storage: str, temp_c: float
) -> dict:
    """Calculate the detailed benefit of switching from current
    storage to a specific preservation method. Shows extra hours
    gained, cost in rupees, money saved, and ROI. Call this for
    each method you want to recommend."""
    return calculate_preservation_benefit(crop, method_id, current_storage, temp_c)


@tool
def check_current_freshness(
    crop: str, storage_method: str, temp_c: float
) -> dict:
    """Check how many hours remain with the farmer's current
    storage method at current temperature. Use this to show
    the baseline before recommending improvements."""
    return predict_remaining_hours(crop, storage_method, temp_c)


# ─── System Prompt ────────────────────────────────────────────

PRESERVATION_SYSTEM_PROMPT = """You are AgriChain's Preservation Advisor Agent for Indian farmers.

YOUR PROCESS — follow these steps IN ORDER:
1. Call check_current_freshness to see how long the crop lasts with current storage
2. Call fetch_preservation_options to get available methods
3. For the top 2-3 methods, call calculate_benefit to get detailed cost/benefit numbers
4. Present methods ranked by value — free methods ALWAYS first
5. STOP after giving your answer.

RULES:
- ALWAYS show the math: "This costs ₹50 but saves ₹800 of crop"
- Free methods (wet jute bags, shade covering) MUST be listed first, always
- Include physical instructions for each method — the farmer needs to know exactly what to do with their hands, step by step
- Never recommend cold storage without mentioning how to find one nearby or the typical daily rental cost
- If only 1-2 days of freshness remain with current storage, emphasize URGENCY — act today, not tomorrow
- Keep response under 150 words
- Respond in the language requested"""


# ─── Agent Singleton ──────────────────────────────────────────

_preservation_agent = None


def get_preservation_agent():
    global _preservation_agent
    if _preservation_agent is None:
        llm = ChatGoogleGenerativeAI(
            model="gemini-2.0-flash",
            temperature=0.3,
            google_api_key=os.getenv("GOOGLE_API_KEY", ""),
        )
        _preservation_agent = create_react_agent(
            llm,
            [fetch_preservation_options, calculate_benefit, check_current_freshness],
            prompt=PRESERVATION_SYSTEM_PROMPT,
        )
    return _preservation_agent


# ─── Public Run Function ─────────────────────────────────────

def run_preservation_agent(
    crop: str,
    current_storage: str,
    temp_c: float,
    language: str = "hindi",
) -> dict:
    try:
        agent = get_preservation_agent()
        user_msg = (
            f"The farmer stores {crop} using {current_storage}. "
            f"Current temperature: {temp_c}°C. "
            f"What preservation methods should they use? "
            f"Respond in {language}."
        )
        result = agent.invoke(
            {"messages": [{"role": "user", "content": user_msg}]},
            config={"recursion_limit": 10},
        )
        return {
            "explanation": result["messages"][-1].content,
            "success": True,
        }
    except Exception as e:
        print(f"Preservation agent error: {e}")
        fallback = generate_explanation_safe(
            {"crop": crop, "method": "cold storage", "cost": 200},
            language,
            "preservation",
        )
        return {"explanation": fallback, "success": False, "error": str(e)}


if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv()
    print("Testing preservation agent...")
    result = run_preservation_agent("tomato", "open_floor", 36.0, "hindi")
    print(f"Success: {result['success']}")
    print(f"Explanation: {result['explanation'][:500]}")
