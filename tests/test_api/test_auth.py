"""Tests for the /auth endpoints."""


def test_send_otp_returns_success(client):
    """POST /auth/send-otp should return success for a valid phone number."""
    response = client.post(
        "/auth/send-otp",
        json={"phone": "9999999999"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data.get("success") is True or data.get("message") is not None


def test_verify_otp_correct(client):
    """POST /auth/verify-otp with correct OTP should return a token."""
    response = client.post(
        "/auth/verify-otp",
        json={"phone": "9999999999", "otp": "123456"},
    )
    assert response.status_code == 200
    data = response.json()
    assert "token" in data or "access_token" in data


def test_verify_otp_wrong_otp(client):
    """POST /auth/verify-otp with wrong OTP should return 401."""
    response = client.post(
        "/auth/verify-otp",
        json={"phone": "9999999999", "otp": "000000"},
    )
    assert response.status_code == 401
