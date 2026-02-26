"""Smoke tests for orchestrator (intent detection + routing)."""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

import pytest
from backend.orchestrator.router import detect_intent, orchestrate


@pytest.mark.slow
def test_harvest_intent():
    assert detect_intent("Should I harvest today?") == "HARVEST"


@pytest.mark.slow
def test_market_intent():
    assert detect_intent("Where to sell my crop?") == "MARKET"


@pytest.mark.slow
def test_spoilage_intent():
    assert detect_intent("How long will my tomatoes last?") == "SPOILAGE"


@pytest.mark.slow
def test_preservation_intent():
    assert detect_intent("How to keep crop fresh?") == "PRESERVATION"


@pytest.mark.slow
def test_full_orchestrate():
    user_data = {
        "crop": "tomato",
        "lat": 21.1458,
        "lng": 79.0882,
        "language": "english",
    }
    result = orchestrate("Should I harvest?", user_data)
    assert "intent" in result
    assert "response" in result
    assert len(result["response"]) > 0
