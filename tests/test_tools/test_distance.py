"""Tests for backend/tools/distance.py"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from backend.tools.distance import (
    haversine_distance,
    estimate_travel_time,
    estimate_fuel_cost,
    calculate_transit_spoilage_pct,
)


def test_nagpur_to_amravati():
    """Nagpur to Amravati should be approximately 140-160 km."""
    d = haversine_distance(21.1458, 79.0882, 20.9374, 77.7796)
    assert 130 <= d <= 160, f"Expected 130-160 km, got {d}"


def test_same_point_zero_distance():
    """Distance from a point to itself should be 0."""
    d = haversine_distance(21.1, 79.0, 21.1, 79.0)
    assert d == 0.0


def test_travel_time_calculation():
    """150 km at 30 km/h should be 300 minutes."""
    t = estimate_travel_time(150, avg_speed_kmh=30)
    assert t == 300.0


def test_fuel_cost_round_trip():
    """100 km round trip at ₹8/km = ₹1600."""
    c = estimate_fuel_cost(100, rate_per_km=8.0, round_trip=True)
    assert c == 1600.0


def test_fuel_cost_one_way():
    """100 km one way at ₹8/km = ₹800."""
    c = estimate_fuel_cost(100, rate_per_km=8.0, round_trip=False)
    assert c == 800.0


def test_transit_spoilage_positive():
    """Long distance transit should produce positive spoilage."""
    s = calculate_transit_spoilage_pct(200, "tomato", 32)
    assert s > 0


def test_transit_spoilage_capped():
    """Even for huge distances, spoilage should not exceed 50%."""
    s = calculate_transit_spoilage_pct(5000, "tomato", 40)
    assert s <= 50.0


def test_transit_spoilage_unknown_crop():
    """Unknown crop should return default 5.0%."""
    s = calculate_transit_spoilage_pct(100, "dragonfruit", 30)
    assert s == 5.0
