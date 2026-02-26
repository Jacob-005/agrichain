"""Tests for the /harvest endpoints."""


def test_harvest_score_returns_valid_structure(client, auth_headers):
    """POST /harvest/score should return a valid score structure."""
    payload = {
        "crop_id": "tomato",
        "quantity_kg": 800,
        "soil_type": "black",
        "temperature": 32,
        "humidity": 65,
    }
    response = client.post("/harvest/score", json=payload, headers=auth_headers)
    assert response.status_code == 200

    data = response.json()
    assert "score" in data or "harvest_score" in data
    score = data.get("score") or data.get("harvest_score")
    assert isinstance(score, (int, float))
    assert 0 <= score <= 100
