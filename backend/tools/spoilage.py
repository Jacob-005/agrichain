"""
spoilage.py — Crop spoilage prediction based on storage method, temperature, and time.

Loads spoilage_data.json. Integrates with weather tool for live conditions.
"""

import json
import os

from backend.tools.weather import get_current_weather, detect_heatwave_risk

DATA_PATH = os.path.join(
    os.path.dirname(__file__), "..", "..", "data", "spoilage_data.json"
)

with open(DATA_PATH, encoding="utf-8") as f:
    SPOILAGE_DATA = json.load(f)


def _get_temp_band(temp_c: float) -> str:
    """Determine temperature band from temperature in Celsius."""
    if temp_c < 25:
        return "below_25"
    elif temp_c <= 35:
        return "25_to_35"
    else:
        return "above_35"


def predict_remaining_hours(
    crop: str,
    storage_method: str,
    temp_c: float,
    hours_since_harvest: float = 0,
) -> dict:
    """
    Predict remaining shelf life for a crop under given conditions.

    Returns a dict with remaining hours, spoilage %, risk level, and color.
    """
    crop_lower = crop.lower().strip()

    if crop_lower not in SPOILAGE_DATA:
        return {"error": f"Crop not found: {crop}"}

    crop_data = SPOILAGE_DATA[crop_lower]

    # Validate storage method, default to open_floor
    if storage_method not in crop_data["storage_methods"]:
        storage_method = "open_floor"

    temp_band = _get_temp_band(temp_c)
    base_hours = crop_data["storage_methods"][storage_method][temp_band]

    # Dynamic reduction for extreme heat (>35°C)
    if temp_c > 35:
        rate = crop_data.get("spoilage_rate_per_degree_above_35", 0.05)
        degrees_above = temp_c - 35
        reduction = rate * degrees_above
        base_hours = base_hours * (1 - reduction)
        base_hours = max(base_hours, 1)  # never go below 1 hour

    remaining_hours = max(0, base_hours - hours_since_harvest)

    if base_hours > 0:
        spoilage_pct = round(((base_hours - remaining_hours) / base_hours) * 100, 1)
    else:
        spoilage_pct = 100.0

    # Risk level
    if remaining_hours > 48:
        risk_level = "low"
        color = "green"
    elif remaining_hours > 12:
        risk_level = "medium"
        color = "yellow"
    else:
        risk_level = "high"
        color = "red"

    return {
        "crop": crop,
        "storage_method": storage_method,
        "temp_c": temp_c,
        "temp_band": temp_band,
        "total_safe_hours": round(base_hours, 1),
        "hours_since_harvest": hours_since_harvest,
        "remaining_hours": round(remaining_hours, 1),
        "remaining_days": round(remaining_hours / 24, 1),
        "spoilage_pct": spoilage_pct,
        "risk_level": risk_level,
        "color": color,
    }


def check_spoilage_with_weather(
    crop: str,
    storage_method: str,
    hours_since_harvest: float,
    lat: float,
    lng: float,
) -> dict:
    """
    Check spoilage using real-time weather data from the weather tool.
    """
    weather = get_current_weather(lat, lng)
    heatwave = detect_heatwave_risk(lat, lng)

    result = predict_remaining_hours(
        crop, storage_method, weather["temp_c"], hours_since_harvest
    )

    if "error" in result:
        return result

    result["weather"] = weather

    if heatwave.get("alert"):
        result["heatwave_alert"] = heatwave
        # Also calculate projected remaining if heatwave hits
        projected = predict_remaining_hours(
            crop, storage_method, heatwave["max_temp"], hours_since_harvest
        )
        result["projected_if_heatwave"] = projected.get("remaining_hours", 0)

    return result


if __name__ == "__main__":
    print("=== Spoilage Tool Self-Test ===")

    tests = [
        ("tomato", "open_floor", 38, 0),
        ("tomato", "open_floor", 38, 12),
        ("tomato", "cold_storage", 25, 0),
        ("onion", "open_floor", 30, 0),
    ]

    for crop, method, temp, hrs in tests:
        r = predict_remaining_hours(crop, method, temp, hrs)
        print(f"{crop}/{method}/{temp}°C/{hrs}h → {r.get('remaining_hours')}h left ({r.get('risk_level')})")
