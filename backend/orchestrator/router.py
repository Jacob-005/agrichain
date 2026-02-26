"""
router.py — Intent detection and agent routing orchestrator.

Classifies farmer messages and routes them to the appropriate agent.
Single entry point for the /chat endpoint.
"""

import os
from langchain_google_genai import ChatGoogleGenerativeAI

from backend.agents.harvest_agent import run_harvest_agent
from backend.agents.market_agent import run_market_agent
from backend.agents.spoilage_agent import run_spoilage_agent
from backend.agents.preservation_agent import run_preservation_agent


def detect_intent(user_message: str) -> str:
    """Classify a farmer's message into one of 4 categories."""
    try:
        llm = ChatGoogleGenerativeAI(
            model="gemini-2.0-flash",
            temperature=0,
            google_api_key=os.getenv("GOOGLE_API_KEY", ""),
        )
        prompt = (
            "Classify this Indian farmer's message into exactly "
            "ONE category.\n\n"
            "HARVEST — asking about when to harvest, crop readiness, "
            "harvest timing, should I pick my crop, is it ready\n"
            "MARKET — asking about where to sell, which mandi, "
            "best price, selling, how much will I get, pocket cash\n"
            "SPOILAGE — asking about freshness, how long will it "
            "last, is my crop going bad, shelf life, rotting\n"
            "PRESERVATION — asking about how to keep fresh, save "
            "my crop, storage tips, prevent rotting, delay selling\n\n"
            f"Farmer's message: '{user_message}'\n\n"
            "Reply with ONLY the category name in caps. Nothing else."
        )
        response = llm.invoke(prompt)
        intent = response.content.strip().upper()
        valid = ["HARVEST", "MARKET", "SPOILAGE", "PRESERVATION"]
        return intent if intent in valid else "HARVEST"
    except Exception as e:
        print(f"Intent detection error: {e}")
        return "HARVEST"


def route_to_agent(intent: str, user_data: dict) -> dict:
    """Route to the correct agent based on detected intent."""
    crop = user_data.get("crop", "tomato")
    lat = user_data.get("lat", 21.1458)
    lng = user_data.get("lng", 79.0882)
    language = user_data.get("language", "hindi")

    if intent == "HARVEST":
        return run_harvest_agent(
            crop,
            lat,
            lng,
            user_data.get("soil_type", "black"),
            user_data.get("district", "Nagpur"),
            language,
        )
    elif intent == "MARKET":
        return run_market_agent(
            crop,
            user_data.get("volume_kg", 500),
            lat,
            lng,
            user_data.get("current_temp_c", 35),
            user_data.get("storage_method", "open_floor"),
            language,
        )
    elif intent == "SPOILAGE":
        return run_spoilage_agent(
            crop,
            user_data.get("storage_method", "open_floor"),
            user_data.get("hours_since_harvest", 0),
            lat,
            lng,
            language,
        )
    elif intent == "PRESERVATION":
        return run_preservation_agent(
            crop,
            user_data.get("storage_method", "open_floor"),
            user_data.get("current_temp_c", 35),
            language,
        )
    else:
        return run_harvest_agent(crop, lat, lng, "black", "Nagpur", language)


def orchestrate(user_message: str, user_data: dict) -> dict:
    """Main entry point: detect intent and route to agent."""
    intent = detect_intent(user_message)
    result = route_to_agent(intent, user_data)
    return {
        "intent": intent,
        "response": result.get("explanation", ""),
        "agent_used": intent.lower(),
        "success": result.get("success", True),
    }


if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv()

    test_messages = [
        "Should I harvest today?",
        "When is the right time to pick my tomatoes?",
        "Where should I sell my crop?",
        "Which mandi gives the best price?",
        "I harvested 6 hours ago. How long will it last?",
        "My tomatoes are going bad, what do I do?",
        "How can I keep my crop fresh longer?",
        "What is the cheapest way to prevent rotting?",
    ]

    for msg in test_messages:
        intent = detect_intent(msg)
        print(f"  '{msg}' → {intent}")
