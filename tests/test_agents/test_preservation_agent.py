"""Smoke tests for preservation agent."""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

import pytest
from backend.agents.preservation_agent import run_preservation_agent


@pytest.mark.slow
def test_preservation_returns_explanation():
    result = run_preservation_agent("tomato", "open_floor",
                                    36.0, "hindi")
    assert "explanation" in result
    assert len(result["explanation"]) > 0


@pytest.mark.slow
def test_preservation_no_crash_bad_input():
    result = run_preservation_agent("unknown", "open_floor",
                                    35.0, "english")
    assert "explanation" in result
