"""
harvest_agent.py — AI agent for calculating harvest readiness scores.

Uses LangGraph with Gemini to orchestrate weather, soil, and market tools
into a harvest recommendation with explanation.
"""

import os
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.prebuilt import create_react_agent
from langchain_core.tools import tool

from backend.tools.weather import get_current_weather, get_weather_forecast
from backend.tools.soil import get_soil_properties
from backend.tools.mandi import get_mandi_prices
from backend.tools.explanation import generate_explanation_safe


# ─── Tool Wrappers ────────────────────────────────────────────

@tool
def fetch_weather(lat: float, lng: float) -> dict:
    """Get current weather conditions at a location. Returns
    temperature in Celsius, humidity percentage, and weather
    description. Use this to check if weather is favorable
    for harvesting."""
    return get_current_weather(lat, lng)


@tool
def fetch_forecast(lat: float, lng: float) -> list:
    """Get weather forecast for next 24 hours at a location.
    Returns list of forecasts at 3-hour intervals. Use this
    to check if rain is coming or temperature will change."""
    return get_weather_forecast(lat, lng)


@tool
def fetch_soil_info(soil_type: str) -> dict:
    """Get soil properties for a given soil type. Returns
    moisture factor, suitable crops, and characteristics.
    Valid types: black, red, alluvial, laterite, sandy, clayey."""
    return get_soil_properties(soil_type)


@tool
def fetch_market_prices(crop: str) -> list:
    """Get current mandi (market) prices for a crop across
    all nearby mandis. Returns list of mandis with price_per_kg.
    Use this to assess market demand and price trends."""
    return get_mandi_prices(crop)


@tool
def compute_harvest_score(
    temp_c: float, humidity_pct: int, rain_forecast: bool,
    avg_mandi_price: float, price_trend: str,
    soil_moisture_factor: float
) -> dict:
    """Calculate the harvest readiness score (0-100) based on
    weather, market, and soil conditions. ALWAYS call this
    after gathering data from other tools.
    price_trend must be: 'rising', 'stable', or 'falling'.
    Returns: score, color, recommendation, breakdown."""
    # Weather subscore (0-30)
    weather_score = 30
    if temp_c > 40:
        weather_score -= 15
    elif temp_c > 35:
        weather_score -= 8
    if humidity_pct > 80:
        weather_score -= 10
    if rain_forecast:
        weather_score -= 15
    weather_score = max(0, min(30, weather_score))

    # Market subscore (0-40)
    if price_trend == "falling":
        market_score = 40  # sell now before price drops
    elif price_trend == "stable":
        market_score = 25
    else:  # rising
        market_score = 10  # wait for better price
    if avg_mandi_price > 20:
        market_score += 10
    elif avg_mandi_price < 10:
        market_score -= 10
    market_score = max(0, min(40, market_score))

    # Readiness subscore (0-30)
    readiness_score = min(30, max(0, int(20 * soil_moisture_factor)))

    total = max(0, min(100, weather_score + market_score + readiness_score))

    if total >= 80:
        color, rec = "green", "Harvest now — conditions are excellent!"
    elif total >= 50:
        color, rec = "yellow", "Consider harvesting — conditions are fair"
    else:
        color, rec = "red", "Wait — conditions are not favorable yet"

    return {
        "score": total,
        "color": color,
        "recommendation": rec,
        "breakdown": {
            "weather": weather_score,
            "market": market_score,
            "readiness": readiness_score,
        },
    }


# ─── System Prompt ────────────────────────────────────────────

HARVEST_SYSTEM_PROMPT = """You are AgriChain's Harvest Score Agent for Indian farmers.

YOUR PROCESS — follow these steps IN THIS EXACT ORDER:
1. Call fetch_weather to get current conditions at the farmer's location
2. Call fetch_forecast to check for rain in the next 24 hours
3. Call fetch_soil_info to get soil moisture properties
4. Call fetch_market_prices to check mandi prices and assess demand
5. From the market prices, calculate the average price and determine the trend (rising/stable/falling). If you cannot determine trend, use "stable".
6. Call compute_harvest_score with ALL gathered data
7. Give your final answer with the score and explanation

RULES:
- NEVER guess or invent data. ALWAYS use the tools.
- ALWAYS call compute_harvest_score — never calculate the score manually.
- Your final response MUST include: the score number out of 100, the color (green/yellow/red), the recommendation, and a 2-3 sentence explanation a farmer with limited education can understand.
- Mention specific rupee (₹) amounts when discussing prices.
- If weather data shows rain coming, mention it explicitly.
- Respond in the language requested by the user. If Hindi, use simple Hindi in Devanagari script.
- After step 7, STOP. Do not call any more tools."""


# ─── Agent Singleton ──────────────────────────────────────────

_harvest_agent = None


def get_harvest_agent():
    global _harvest_agent
    if _harvest_agent is None:
        llm = ChatGoogleGenerativeAI(
            model="gemini-2.0-flash",
            temperature=0.3,
            google_api_key=os.getenv("GOOGLE_API_KEY", ""),
        )
        tools = [
            fetch_weather,
            fetch_forecast,
            fetch_soil_info,
            fetch_market_prices,
            compute_harvest_score,
        ]
        _harvest_agent = create_react_agent(
            llm, tools, prompt=HARVEST_SYSTEM_PROMPT
        )
    return _harvest_agent


# ─── Public Run Function ─────────────────────────────────────

def run_harvest_agent(
    crop: str,
    lat: float,
    lng: float,
    soil_type: str,
    district: str,
    language: str = "hindi",
) -> dict:
    try:
        agent = get_harvest_agent()
        user_msg = (
            f"The farmer grows {crop} in {district}. "
            f"Location: lat={lat}, lng={lng}. "
            f"Soil type: {soil_type}. "
            f"Please calculate the harvest score and explain "
            f"in {language}."
        )
        result = agent.invoke(
            {"messages": [{"role": "user", "content": user_msg}]},
            config={"recursion_limit": 10},
        )
        final_message = result["messages"][-1].content
        return {"explanation": final_message, "success": True}
    except Exception as e:
        print(f"Harvest agent error: {e}")
        fallback = generate_explanation_safe(
            {"score": 65, "crop": crop}, language, "harvest"
        )
        return {"explanation": fallback, "success": False, "error": str(e)}


if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv()
    print("Testing harvest agent...")
    result = run_harvest_agent(
        "tomato", 21.1458, 79.0882, "black", "Nagpur", "hindi"
    )
    print(f"Success: {result['success']}")
    print(f"Explanation: {result['explanation'][:500]}")
