"""Tests for backend/tools/weather.py"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from backend.tools.weather import get_current_weather, get_weather_forecast, detect_heatwave_risk


def test_get_current_weather_returns_dict():
    """Weather should always return a dict."""
    result = get_current_weather(21.1458, 79.0882)
    assert isinstance(result, dict)


def test_weather_has_required_fields():
    """Weather result must have temp_c, humidity_pct, description."""
    result = get_current_weather(21.1458, 79.0882)
    assert "temp_c" in result
    assert "humidity_pct" in result
    assert "description" in result


def test_temp_in_reasonable_range():
    """Temperature should be between -10 and 60°C."""
    result = get_current_weather(21.1458, 79.0882)
    assert -10 <= result["temp_c"] <= 60


def test_humidity_in_range():
    """Humidity should be between 0 and 100%."""
    result = get_current_weather(21.1458, 79.0882)
    assert 0 <= result["humidity_pct"] <= 100


def test_detect_heatwave_returns_alert_key():
    """Heatwave detection should return dict with 'alert' key."""
    result = detect_heatwave_risk(21.1458, 79.0882)
    assert "alert" in result
    assert isinstance(result["alert"], bool)


def test_weather_with_invalid_coords():
    """Weather with unusual coords should not crash."""
    result = get_current_weather(0, 0)
    assert isinstance(result, dict)
    assert "temp_c" in result


def test_forecast_returns_list():
    """Forecast should return a list of entries."""
    result = get_weather_forecast(21.1458, 79.0882)
    assert isinstance(result, list)
    assert len(result) > 0


def test_forecast_entries_have_temp():
    """Each forecast entry should have temp_c."""
    result = get_weather_forecast(21.1458, 79.0882)
    for entry in result:
        assert "temp_c" in entry
