"""Tests for backend/tools/soil.py"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from backend.tools.soil import get_soil_properties, get_moisture_factor, get_suitable_crops


VALID_SOIL_IDS = ["black", "alluvial", "red", "laterite", "sandy", "clayey"]


def test_all_soil_types_exist():
    """All 6 soil types should return valid properties (no error key)."""
    for sid in VALID_SOIL_IDS:
        result = get_soil_properties(sid)
        assert "error" not in result, f"Soil '{sid}' returned error: {result}"


def test_moisture_factor_range():
    """Moisture factor should be between 0.3 and 1.5 for all soils."""
    for sid in VALID_SOIL_IDS:
        mf = get_moisture_factor(sid)
        assert 0.3 <= mf <= 1.5, f"Soil '{sid}' moisture_factor {mf} out of range"


def test_unknown_soil_returns_error():
    """Unknown soil type should return error dict."""
    result = get_soil_properties("martian_soil")
    assert "error" in result


def test_suitable_crops_not_empty():
    """Each soil type should have at least 1 suitable crop."""
    for sid in VALID_SOIL_IDS:
        crops = get_suitable_crops(sid)
        assert len(crops) >= 1, f"Soil '{sid}' has no suitable crops"


def test_soil_has_color_hex():
    """Each soil should have a color_hex field."""
    for sid in VALID_SOIL_IDS:
        props = get_soil_properties(sid)
        assert "color_hex" in props, f"Soil '{sid}' missing color_hex"


def test_case_insensitive_lookup():
    """Lookup should be case-insensitive."""
    result_lower = get_soil_properties("black")
    result_upper = get_soil_properties("BLACK")
    assert result_lower["id"] == result_upper["id"]


def test_soil_has_hindi_name():
    """Each soil should have a Hindi name."""
    for sid in VALID_SOIL_IDS:
        props = get_soil_properties(sid)
        assert "name_hi" in props, f"Soil '{sid}' missing name_hi"
        assert len(props["name_hi"]) > 0
