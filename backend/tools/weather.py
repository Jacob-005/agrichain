"""
weather.py — Current weather and forecast from OpenWeatherMap API.

Falls back to hardcoded data if no API key is set or API call fails.
"""

import os

import httpx

API_KEY = os.getenv("OPENWEATHER_API_KEY", "")

FALLBACK_WEATHER = {
    "temp_c": 35.0,
    "humidity_pct": 45,
    "description": "unknown (fallback)",
    "wind_speed_ms": 2.0,
    "feels_like_c": 37.0,
    "is_fallback": True,
}


def get_current_weather(lat: float, lng: float) -> dict:
    """
    Fetch current weather for given coordinates.
    Returns fallback data if API key missing or call fails.
    """
    if not API_KEY:
        return dict(FALLBACK_WEATHER)

    try:
        url = (
            f"http://api.openweathermap.org/data/2.5/weather"
            f"?lat={lat}&lon={lng}&appid={API_KEY}&units=metric"
        )
        resp = httpx.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()

        return {
            "temp_c": data["main"]["temp"],
            "humidity_pct": data["main"]["humidity"],
            "description": data["weather"][0]["description"],
            "wind_speed_ms": data["wind"]["speed"],
            "feels_like_c": data["main"]["feels_like"],
            "is_fallback": False,
        }
    except Exception as e:
        print(f"Weather API error: {e}")
        return dict(FALLBACK_WEATHER)


def get_weather_forecast(lat: float, lng: float) -> list:
    """
    Fetch weather forecast (next 24 hours, 8 x 3-hour intervals).
    Returns 8 fallback entries if API key missing or call fails.
    """
    if not API_KEY:
        return [dict(FALLBACK_WEATHER) for _ in range(8)]

    try:
        url = (
            f"http://api.openweathermap.org/data/2.5/forecast"
            f"?lat={lat}&lon={lng}&appid={API_KEY}&units=metric"
        )
        resp = httpx.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()

        entries = []
        for item in data["list"][:8]:
            entries.append({
                "datetime": item["dt_txt"],
                "temp_c": item["main"]["temp"],
                "humidity_pct": item["main"]["humidity"],
                "description": item["weather"][0]["description"],
                "is_fallback": False,
            })
        return entries

    except Exception as e:
        print(f"Forecast API error: {e}")
        return [dict(FALLBACK_WEATHER) for _ in range(8)]


def detect_heatwave_risk(lat: float, lng: float) -> dict:
    """
    Detect heatwave risk by comparing current temp with forecast max.
    """
    current = get_current_weather(lat, lng)
    forecast = get_weather_forecast(lat, lng)

    current_temp = current["temp_c"]
    max_temp = max((f.get("temp_c", current_temp) for f in forecast), default=current_temp)

    if max_temp > current_temp + 5:
        return {
            "alert": True,
            "message": f"Heatwave expected. Temperature rising to {max_temp}°C",
            "max_temp": max_temp,
            "current_temp": current_temp,
        }
    return {
        "alert": False,
        "max_temp": max_temp,
        "current_temp": current_temp,
    }


if __name__ == "__main__":
    print("=== Weather Tool Self-Test ===")
    w = get_current_weather(21.1458, 79.0882)
    print(f"Nagpur weather: {w}")

    hw = detect_heatwave_risk(21.1458, 79.0882)
    print(f"Heatwave risk: {hw}")
