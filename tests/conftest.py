"""
AgriChain Test Configuration
Shared fixtures for API integration tests and tool unit tests.
"""

import json
import os
import pytest
import httpx
from dotenv import load_dotenv

load_dotenv()

BASE_URL = os.getenv("AGRICHAIN_API_URL", "http://localhost:8000/api/v1")
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")


# ─── API Fixtures ─────────────────────────────────────────────

@pytest.fixture(scope="session")
def base_url():
    """Provide the backend API base URL."""
    return BASE_URL


@pytest.fixture(scope="session")
def client():
    """Provide an httpx client scoped to the whole test session."""
    with httpx.Client(base_url=BASE_URL, timeout=30.0) as c:
        yield c


@pytest.fixture(scope="session")
def auth_token(client):
    """
    Obtain a valid auth token by calling /auth/verify-otp
    with the test phone number and OTP.
    """
    response = client.post(
        "/auth/verify-otp",
        json={"phone": "9999999999", "otp": "123456"},
    )
    assert response.status_code == 200, f"Auth failed: {response.text}"
    data = response.json()
    return data.get("token") or data.get("access_token")


@pytest.fixture(scope="session")
def auth_headers(auth_token):
    """Provide Authorization headers using the obtained token."""
    return {"Authorization": f"Bearer {auth_token}"}


# ─── Data File Fixtures ───────────────────────────────────────

@pytest.fixture(scope="session")
def crops_data():
    with open(os.path.join(DATA_DIR, "crops.json"), encoding="utf-8") as f:
        return json.load(f)


@pytest.fixture(scope="session")
def soil_types_data():
    with open(os.path.join(DATA_DIR, "soil_types.json"), encoding="utf-8") as f:
        return json.load(f)


@pytest.fixture(scope="session")
def mandi_data():
    with open(os.path.join(DATA_DIR, "mandi_prices.json"), encoding="utf-8") as f:
        return json.load(f)


@pytest.fixture(scope="session")
def spoilage_data():
    with open(os.path.join(DATA_DIR, "spoilage_data.json"), encoding="utf-8") as f:
        return json.load(f)


@pytest.fixture(scope="session")
def preservation_data():
    with open(os.path.join(DATA_DIR, "preservation_methods.json"), encoding="utf-8") as f:
        return json.load(f)


# ─── Coordinate Fixtures ──────────────────────────────────────

@pytest.fixture
def nagpur_coords():
    return (21.1458, 79.0882)


@pytest.fixture
def amravati_coords():
    return (20.9374, 77.7796)


@pytest.fixture
def mumbai_coords():
    return (19.0760, 72.8777)


# ─── Environment Fixtures ─────────────────────────────────────

@pytest.fixture
def mock_no_api_keys(monkeypatch):
    """Remove API keys to test fallback behavior."""
    monkeypatch.delenv("OPENWEATHER_API_KEY", raising=False)
    monkeypatch.delenv("GOOGLE_API_KEY", raising=False)
