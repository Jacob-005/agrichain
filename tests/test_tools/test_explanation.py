"""Tests for backend/tools/explanation.py"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from backend.tools.explanation import generate_explanation_safe, FALLBACK_RESPONSES


SAMPLE_CONTEXT = {
    "score": 78,
    "crop": "tomato",
    "temp_c": 35,
    "price_trend": "rising",
    "recommended_mandi": "Kalamna Mandi",
    "remaining_hours": 36,
    "method": "clay pot cooling",
    "cost": 50,
}


def test_safe_always_returns_string():
    """generate_explanation_safe should always return a string."""
    result = generate_explanation_safe(SAMPLE_CONTEXT, "hindi", "harvest")
    assert isinstance(result, str)
    assert len(result) > 0


def test_fallback_on_missing_api_key(monkeypatch):
    """With no API key, should return fallback (non-empty string)."""
    monkeypatch.delenv("GOOGLE_API_KEY", raising=False)
    # Reset the LLM singleton so it re-initializes
    import backend.tools.explanation as exp
    exp._llm = None

    result = generate_explanation_safe(SAMPLE_CONTEXT, "hindi", "harvest")
    assert isinstance(result, str)
    assert len(result) > 0


def test_all_explanation_types():
    """All 4 explanation types should return non-empty strings."""
    for etype in ["harvest", "market", "spoilage", "preservation"]:
        result = generate_explanation_safe(SAMPLE_CONTEXT, "hindi", etype)
        assert isinstance(result, str), f"Type '{etype}' did not return string"
        assert len(result) > 0, f"Type '{etype}' returned empty string"


def test_fallback_contains_useful_info(monkeypatch):
    """Fallback for 'harvest' should contain the score."""
    monkeypatch.delenv("GOOGLE_API_KEY", raising=False)
    import backend.tools.explanation as exp
    exp._llm = None

    result = generate_explanation_safe(SAMPLE_CONTEXT, "hindi", "harvest")
    assert "78" in result, "Fallback should contain the score value"
