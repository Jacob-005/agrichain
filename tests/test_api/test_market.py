"""Tests for the /market endpoints."""


def test_market_compare_returns_mandis(client, auth_headers):
    """POST /market/compare should return an array of mandi options."""
    payload = {
        "crop_id": "tomato",
        "quantity_kg": 800,
        "lat": 21.1458,
        "lng": 79.0882,
    }
    response = client.post("/market/compare", json=payload, headers=auth_headers)
    assert response.status_code == 200

    data = response.json()
    mandis = data.get("mandis") or data.get("markets") or data
    assert isinstance(mandis, list)
    assert len(mandis) > 0

    first = mandis[0]
    assert "mandi" in first or "name" in first
    assert "price_per_kg" in first or "price" in first
