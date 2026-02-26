"""
formatter.py — Structured response formatting for all agent types.

Parses agent text output into structured dicts for mobile app consumption.
"""

import re


def format_harvest_response(raw_explanation: str, user_data: dict) -> dict:
    score_match = re.search(r"(\d{1,3})/100", raw_explanation)
    score = int(score_match.group(1)) if score_match else 65

    if score >= 80:
        color, action = "green", "harvest_now"
    elif score >= 50:
        color, action = "yellow", "wait"
    else:
        color, action = "red", "do_not_harvest"

    return {
        "type": "harvest_score",
        "score": score,
        "color": color,
        "action": action,
        "explanation_text": raw_explanation,
        "crop": user_data.get("crop"),
        "show_voice_button": True,
    }


def format_market_response(raw_explanation: str, user_data: dict) -> dict:
    return {
        "type": "market_comparison",
        "explanation_text": raw_explanation,
        "crop": user_data.get("crop"),
        "volume_kg": user_data.get("volume_kg"),
        "show_voice_button": True,
    }


def format_spoilage_response(raw_explanation: str, user_data: dict) -> dict:
    hours_match = re.search(
        r"(\d+\.?\d*)\s*hours?", raw_explanation, re.IGNORECASE
    )
    remaining = float(hours_match.group(1)) if hours_match else 24

    if remaining > 48:
        color, urgency = "green", "safe"
    elif remaining > 12:
        color, urgency = "yellow", "attention"
    else:
        color, urgency = "red", "urgent"

    has_alert = any(
        w in raw_explanation.lower()
        for w in ["alert", "⚠️", "heatwave", "warning"]
    )

    return {
        "type": "spoilage_timer",
        "remaining_hours": remaining,
        "remaining_days": round(remaining / 24, 1),
        "color": color,
        "urgency": urgency,
        "has_weather_alert": has_alert,
        "vibrate_phone": color == "red",
        "explanation_text": raw_explanation,
        "show_voice_button": True,
    }


def format_preservation_response(raw_explanation: str, user_data: dict) -> dict:
    return {
        "type": "preservation_list",
        "explanation_text": raw_explanation,
        "crop": user_data.get("crop"),
        "current_storage": user_data.get("storage_method"),
        "show_voice_button": True,
    }


def format_response(
    intent: str, raw_explanation: str, user_data: dict
) -> dict:
    formatters = {
        "HARVEST": format_harvest_response,
        "MARKET": format_market_response,
        "SPOILAGE": format_spoilage_response,
        "PRESERVATION": format_preservation_response,
    }
    formatter = formatters.get(intent, format_harvest_response)
    formatted = formatter(raw_explanation, user_data)
    return {"success": True, "data": formatted}
