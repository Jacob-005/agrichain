"""Tests for the /preservation endpoints."""


def test_preservation_options_returns_methods(client, auth_headers):
    """POST /preservation/options should return an array of methods."""
    payload = {
        "crop_id": "tomato",
        "budget_rupees": 100,
    }
    response = client.post("/preservation/options", json=payload, headers=auth_headers)
    assert response.status_code == 200

    data = response.json()
    methods = data.get("methods") or data.get("options") or data
    assert isinstance(methods, list)
    assert len(methods) > 0

    first = methods[0]
    assert "name_en" in first or "name" in first
    assert "cost_rupees" in first or "cost" in first
