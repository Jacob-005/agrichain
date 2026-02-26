"""Tests for the /spoilage endpoints."""


def test_spoilage_check_returns_remaining_hours(client, auth_headers):
    """POST /spoilage/check should return remaining_hours."""
    payload = {
        "crop_id": "tomato",
        "storage_method": "open_floor",
        "temperature": 32,
        "hours_since_harvest": 12,
    }
    response = client.post("/spoilage/check", json=payload, headers=auth_headers)
    assert response.status_code == 200

    data = response.json()
    assert "remaining_hours" in data
    assert isinstance(data["remaining_hours"], (int, float))
    assert data["remaining_hours"] >= 0
