"""Tests for backend/tools/spoilage.py"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from backend.tools.spoilage import predict_remaining_hours


def test_higher_temp_less_hours():
    """Tomato at 40°C should have fewer remaining hours than at 25°C."""
    hot = predict_remaining_hours("tomato", "open_floor", 40, 0)
    cool = predict_remaining_hours("tomato", "open_floor", 25, 0)
    assert hot["remaining_hours"] < cool["remaining_hours"]


def test_hours_since_harvest_reduces_remaining():
    """Remaining hours should decrease as hours_since_harvest increases."""
    fresh = predict_remaining_hours("tomato", "open_floor", 30, 0)
    aged = predict_remaining_hours("tomato", "open_floor", 30, 12)
    assert aged["remaining_hours"] < fresh["remaining_hours"]


def test_cold_storage_longest():
    """Cold storage should give more hours than open floor at same temp."""
    cold = predict_remaining_hours("tomato", "cold_storage", 30, 0)
    open_f = predict_remaining_hours("tomato", "open_floor", 30, 0)
    assert cold["remaining_hours"] > open_f["remaining_hours"]


def test_risk_level_high_for_urgent():
    """Very high temp + many hours elapsed should give 'high' risk."""
    result = predict_remaining_hours("cauliflower", "open_floor", 40, 10)
    assert result["risk_level"] == "high"


def test_risk_level_low_for_fresh():
    """Freshly harvested in cold storage should be 'low' risk."""
    result = predict_remaining_hours("tomato", "cold_storage", 25, 0)
    assert result["risk_level"] == "low"


def test_color_matches_risk():
    """Colors should match risk levels: green/low, yellow/medium, red/high."""
    mapping = {"low": "green", "medium": "yellow", "high": "red"}
    for crop, method, temp, hrs in [
        ("onion", "cold_storage", 25, 0),  # low risk
        ("tomato", "open_floor", 30, 0),   # medium risk
        ("cauliflower", "open_floor", 40, 10),  # high risk
    ]:
        result = predict_remaining_hours(crop, method, temp, hrs)
        expected_color = mapping[result["risk_level"]]
        assert result["color"] == expected_color, (
            f"{crop}: risk={result['risk_level']}, expected color={expected_color}, got={result['color']}"
        )


def test_unknown_crop_returns_error():
    """Unknown crop should return error dict."""
    result = predict_remaining_hours("dragonfruit", "open_floor", 30, 0)
    assert "error" in result


def test_spoilage_pct_between_0_and_100():
    """Spoilage percentage should be between 0 and 100."""
    result = predict_remaining_hours("tomato", "open_floor", 30, 10)
    assert 0 <= result["spoilage_pct"] <= 100
