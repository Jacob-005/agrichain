"""Smoke tests for harvest agent."""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

import pytest
from backend.agents.harvest_agent import run_harvest_agent


@pytest.mark.slow
def test_harvest_returns_explanation():
    result = run_harvest_agent("tomato", 21.1458, 79.0882,
                               "black", "Nagpur", "hindi")
    assert "explanation" in result
    assert len(result["explanation"]) > 0


@pytest.mark.slow
def test_harvest_no_crash_bad_input():
    result = run_harvest_agent("unknown", 0, 0, "unknown", "X", "english")
    assert "explanation" in result
