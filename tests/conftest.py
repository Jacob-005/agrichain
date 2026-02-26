"""
AgriChain Test Configuration
Shared fixtures for API integration tests.
"""

import os
import pytest
import httpx
from dotenv import load_dotenv

load_dotenv()

BASE_URL = os.getenv("AGRICHAIN_API_URL", "http://localhost:8000/api/v1")


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
