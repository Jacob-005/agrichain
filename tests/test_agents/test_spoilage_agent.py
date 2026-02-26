"""Smoke tests for spoilage agent."""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

import pytest
from backend.agents.spoilage_agent import run_spoilage_agent


@pytest.mark.slow
def test_spoilage_returns_explanation():
    result = run_spoilage_agent("tomato", "open_floor", 6,
                                21.1458, 79.0882, "hindi")
    assert "explanation" in result
    assert len(result["explanation"]) > 0


@pytest.mark.slow
def test_spoilage_no_crash_bad_input():
    result = run_spoilage_agent("unknown", "open_floor", 0,
                                0, 0, "english")
    assert "explanation" in result
