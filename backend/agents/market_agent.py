"""
market_agent.py — AI agent for mandi comparison with pocket cash ranking.

Demonstrates that the highest-priced mandi isn't always the best deal
after accounting for fuel costs and transit spoilage.
"""

import os
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.prebuilt import create_react_agent
from langchain_core.tools import tool

from backend.tools.mandi import get_mandi_prices, get_nearby_mandis
from backend.tools.distance import (
    haversine_distance,
    estimate_fuel_cost,
    calculate_transit_spoilage_pct,
)
from backend.tools.weather import get_current_weather
from backend.tools.explanation import generate_explanation_safe


# ─── Tool Wrappers ────────────────────────────────────────────

@tool
def fetch_nearby_mandis(crop: str, lat: float, lng: float) -> list:
    """Get the 3 nearest mandis for a crop sorted by distance.
    Returns list with mandi, price_per_kg, distance_km,
    lat, lng for each."""
    return get_nearby_mandis(crop, lat, lng, max_count=3)


@tool
def fetch_current_temp(lat: float, lng: float) -> dict:
    """Get current temperature at location. Needed to calculate
    how much crop will spoil during transport."""
    return get_current_weather(lat, lng)


@tool
def calculate_pocket_cash(
    crop: str,
    volume_kg: float,
    farmer_lat: float,
    farmer_lng: float,
    mandi_name: str,
    mandi_lat: float,
    mandi_lng: float,
    price_per_kg: float,
    temp_c: float,
    storage_method: str,
) -> dict:
    """Calculate the ACTUAL cash a farmer takes home after
    selling at a specific mandi. Accounts for fuel cost and
    crop spoilage during transport. CALL THIS FOR EVERY MANDI
    to compare them fairly. Returns pocket_cash, fuel_cost,
    spoilage_loss, distance_km, and risk_level."""
    dist = haversine_distance(farmer_lat, farmer_lng, mandi_lat, mandi_lng)
    fuel = estimate_fuel_cost(dist, round_trip=True)
    spoilage_pct = calculate_transit_spoilage_pct(dist, crop, temp_c)
    effective_volume = volume_kg * (1 - spoilage_pct / 100)
    gross = effective_volume * price_per_kg
    pocket = gross - fuel
    spoilage_loss = (volume_kg - effective_volume) * price_per_kg

    if spoilage_pct < 5:
        risk = "low"
    elif spoilage_pct < 15:
        risk = "medium"
    else:
        risk = "high"

    return {
        "mandi_name": mandi_name,
        "distance_km": round(dist, 1),
        "price_per_kg": price_per_kg,
        "fuel_cost": round(fuel, 0),
        "spoilage_pct": round(spoilage_pct, 1),
        "spoilage_loss_rupees": round(spoilage_loss, 0),
        "effective_volume_kg": round(effective_volume, 1),
        "gross_revenue": round(gross, 0),
        "pocket_cash": round(pocket, 0),
        "risk_level": risk,
    }


# ─── System Prompt ────────────────────────────────────────────

MARKET_SYSTEM_PROMPT = """You are AgriChain's Market Comparison Agent for Indian farmers.

YOUR PROCESS — follow these steps IN THIS EXACT ORDER:
1. Call fetch_nearby_mandis to get the 3 nearest mandis for the crop
2. Call fetch_current_temp to get the temperature at the farmer's location (this affects spoilage during transport)
3. For EACH mandi from step 1, call calculate_pocket_cash with all the details. You MUST call it once per mandi — do not skip any.
4. Rank the mandis by pocket_cash (highest first) — NOT by price_per_kg
5. Explain the ranking to the farmer
6. After explaining, STOP. Do not call any more tools.

CRITICAL INSIGHT you must convey to the farmer:
A nearby mandi with a lower price per kg often puts MORE CASH in the farmer's pocket than a distant mandi with a higher price. This is because: less fuel spent on travel + less crop rots during the longer journey. ALWAYS explain this if it applies.

RULES:
- Calculate pocket_cash for EVERY mandi. Never skip one.
- Rank by pocket_cash, NOT by listed price
- For each mandi show: price per kg, distance, fuel cost, spoilage loss in ₹, and final pocket cash
- Use ₹ symbol for all rupee amounts
- Make the pocket_cash number prominent in your response
- If the cheaper-priced mandi wins, explicitly explain WHY
- Keep your response under 150 words
- Respond in the language requested by the user"""


# ─── Agent Singleton ──────────────────────────────────────────

_market_agent = None


def get_market_agent():
    global _market_agent
    if _market_agent is None:
        llm = ChatGoogleGenerativeAI(
            model="gemini-2.0-flash",
            temperature=0.3,
            google_api_key=os.getenv("GOOGLE_API_KEY", ""),
        )
        tools = [fetch_nearby_mandis, fetch_current_temp, calculate_pocket_cash]
        _market_agent = create_react_agent(
            llm, tools, prompt=MARKET_SYSTEM_PROMPT
        )
    return _market_agent


# ─── Public Run Function ─────────────────────────────────────

def run_market_agent(
    crop: str,
    volume_kg: float,
    farmer_lat: float,
    farmer_lng: float,
    current_temp_c: float,
    storage_method: str,
    language: str = "hindi",
) -> dict:
    try:
        agent = get_market_agent()
        user_msg = (
            f"The farmer wants to sell {volume_kg} kg of {crop}. "
            f"Location: lat={farmer_lat}, lng={farmer_lng}. "
            f"Current temperature: {current_temp_c}°C. "
            f"Storage method: {storage_method}. "
            f"Find the best mandi and explain in {language}."
        )
        result = agent.invoke(
            {"messages": [{"role": "user", "content": user_msg}]},
            config={"recursion_limit": 12},
        )
        final_message = result["messages"][-1].content
        return {"explanation": final_message, "success": True}
    except Exception as e:
        print(f"Market agent error: {e}")
        fallback = generate_explanation_safe(
            {"crop": crop, "volume_kg": volume_kg}, language, "market"
        )
        return {"explanation": fallback, "success": False, "error": str(e)}


if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv()
    print("Testing market agent...")
    result = run_market_agent(
        "tomato", 800, 21.1458, 79.0882, 35.0, "open_floor", "hindi"
    )
    print(f"Success: {result['success']}")
    print(f"Explanation: {result['explanation'][:500]}")
