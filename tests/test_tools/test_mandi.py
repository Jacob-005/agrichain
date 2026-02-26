"""Tests for backend/tools/mandi.py"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from backend.tools.mandi import get_mandi_prices, get_nearby_mandis, get_best_pocket_cash_mandi


def test_tomato_prices_exist():
    """Tomato should have at least 2 mandis."""
    prices = get_mandi_prices("tomato")
    assert len(prices) >= 2


def test_unknown_crop_empty_list():
    """Unknown crop should return empty list."""
    prices = get_mandi_prices("dragonfruit")
    assert prices == []


def test_case_insensitive():
    """'Tomato' and 'tomato' should return same number of results."""
    r1 = get_mandi_prices("Tomato")
    r2 = get_mandi_prices("tomato")
    assert len(r1) == len(r2)


def test_nearby_mandis_sorted_by_distance():
    """Nearby mandis should be sorted by distance ascending."""
    nearby = get_nearby_mandis("tomato", 21.1458, 79.0882, max_count=5)
    assert len(nearby) >= 2
    for i in range(len(nearby) - 1):
        assert nearby[i]["distance_km"] <= nearby[i + 1]["distance_km"]


def test_mandi_entries_have_required_fields():
    """Each mandi entry must have mandi, price_per_kg, lat, lng."""
    prices = get_mandi_prices("tomato")
    for entry in prices:
        assert "mandi" in entry, f"Missing 'mandi' field"
        assert "price_per_kg" in entry, f"Missing 'price_per_kg' field"
        assert "lat" in entry, f"Missing 'lat' field"
        assert "lng" in entry, f"Missing 'lng' field"


def test_max_count_limits_results():
    """get_nearby_mandis with max_count=2 should return at most 2."""
    nearby = get_nearby_mandis("tomato", 21.1458, 79.0882, max_count=2)
    assert len(nearby) <= 2


def test_pocket_cash_has_required_fields():
    """Pocket cash results should have distance, transport, pocket_cash fields."""
    results = get_best_pocket_cash_mandi("tomato", 800, 21.1458, 79.0882)
    assert len(results) > 0
    for r in results:
        assert "distance_km" in r
        assert "transport_cost" in r
        assert "gross_revenue" in r
        assert "pocket_cash" in r


def test_pocket_cash_sorted_descending():
    """Results should be sorted by pocket_cash descending."""
    results = get_best_pocket_cash_mandi("tomato", 800, 21.1458, 79.0882)
    for i in range(len(results) - 1):
        assert results[i]["pocket_cash"] >= results[i + 1]["pocket_cash"]
