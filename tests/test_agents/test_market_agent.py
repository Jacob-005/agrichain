"""Smoke tests for market agent."""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

import pytest
from backend.agents.market_agent import run_market_agent


@pytest.mark.slow
def test_market_returns_explanation():
    result = run_market_agent("tomato", 800, 21.1458, 79.0882,
                              35.0, "open_floor", "hindi")
    assert "explanation" in result
    assert len(result["explanation"]) > 0


@pytest.mark.slow
def test_market_no_crash_bad_input():
    result = run_market_agent("unknown", 100, 0, 0,
                              35.0, "open_floor", "english")
    assert "explanation" in result
