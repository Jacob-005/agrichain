"""Tests for backend/tools/preservation.py"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from backend.tools.preservation import get_preservation_options, calculate_preservation_benefit


def test_options_exclude_current_storage():
    """Current storage method should not appear in options."""
    options = get_preservation_options("tomato", current_storage="wet_jute")
    for o in options:
        assert o["id"] != "wet_jute", "Current storage should be excluded"


def test_free_methods_first():
    """Free methods (highest ROI) should appear first."""
    options = get_preservation_options("tomato", current_storage="plastic_crates")
    if len(options) >= 2:
        assert options[0]["roi"] >= options[1]["roi"]


def test_roi_calculated():
    """Every result should have an 'roi' key."""
    options = get_preservation_options("tomato")
    for o in options:
        assert "roi" in o


def test_options_sorted_by_roi():
    """Results should be sorted by ROI descending."""
    options = get_preservation_options("tomato")
    for i in range(len(options) - 1):
        assert options[i]["roi"] >= options[i + 1]["roi"]


def test_unknown_crop_returns_empty():
    """Unknown crop should return empty list."""
    options = get_preservation_options("dragonfruit")
    assert options == []


def test_benefit_shows_extra_hours():
    """Upgrading from open_floor to ZECC should gain extra hours."""
    benefit = calculate_preservation_benefit("tomato", "zecc", "open_floor", 30)
    assert "error" not in benefit
    assert benefit["extra_hours_gained"] > 0


def test_all_options_have_instructions():
    """Every method should have instructions_en field."""
    options = get_preservation_options("tomato")
    for o in options:
        assert "instructions_en" in o, f"Method {o.get('id')} missing instructions_en"


def test_benefit_roi_positive():
    """ROI for upgrading should be positive."""
    benefit = calculate_preservation_benefit("tomato", "zecc", "open_floor", 30)
    assert benefit["roi"] > 0
