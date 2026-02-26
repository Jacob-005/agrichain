"""
mandi.py — Mandi price lookup and nearby mandi search.

Uses mandi_prices.json and the distance tool for proximity calculations.
"""

import json
import os

from backend.tools.distance import haversine_distance

DATA_PATH = os.path.join(
    os.path.dirname(__file__), "..", "..", "data", "mandi_prices.json"
)

with open(DATA_PATH, encoding="utf-8") as f:
    MANDI_DATA = json.load(f)


def get_mandi_prices(crop: str) -> list:
    """
    Get all mandi price entries for a given crop.
    Case-insensitive lookup.
    Returns empty list if crop not found.
    """
    crop_lower = crop.lower().strip()
    return MANDI_DATA.get(crop_lower, [])


def get_nearby_mandis(
    crop: str, user_lat: float, user_lng: float, max_count: int = 3
) -> list:
    """
    Get nearby mandis for a crop, sorted by distance from user location.

    Each entry gets an added 'distance_km' field.
    Returns at most max_count results.
    """
    mandis = get_mandi_prices(crop)
    if not mandis:
        return []

    enriched = []
    for m in mandis:
        entry = dict(m)  # copy to avoid mutating original
        entry["distance_km"] = haversine_distance(
            user_lat, user_lng, m["lat"], m["lng"]
        )
        enriched.append(entry)

    enriched.sort(key=lambda x: x["distance_km"])
    return enriched[:max_count]


def get_best_pocket_cash_mandi(
    crop: str,
    quantity_kg: float,
    user_lat: float,
    user_lng: float,
    fuel_rate_per_km: float = 8.0,
) -> list:
    """
    Calculate pocket cash (net revenue after transport) for each mandi.

    Returns all mandis sorted by pocket_cash descending (best deal first).
    """
    from backend.tools.distance import estimate_fuel_cost

    mandis = get_mandi_prices(crop)
    if not mandis:
        return []

    results = []
    for m in mandis:
        entry = dict(m)
        distance_km = haversine_distance(user_lat, user_lng, m["lat"], m["lng"])
        transport_cost = estimate_fuel_cost(
            distance_km, rate_per_km=fuel_rate_per_km, round_trip=True
        )
        gross_revenue = quantity_kg * m["price_per_kg"]
        pocket_cash = gross_revenue - transport_cost

        entry["distance_km"] = round(distance_km, 1)
        entry["transport_cost"] = round(transport_cost, 2)
        entry["gross_revenue"] = round(gross_revenue, 2)
        entry["pocket_cash"] = round(pocket_cash, 2)
        results.append(entry)

    results.sort(key=lambda x: x["pocket_cash"], reverse=True)

    # Mark the best one
    if results:
        results[0]["recommended"] = True

    return results


if __name__ == "__main__":
    print("=== Mandi Tool Self-Test ===")

    prices = get_mandi_prices("tomato")
    print(f"Tomato mandis: {len(prices)}")

    nearby = get_nearby_mandis("tomato", 21.1458, 79.0882, max_count=3)
    for m in nearby:
        print(f"  {m['mandi']}: ₹{m['price_per_kg']}/kg, {m['distance_km']} km")

    print("\nPocket Cash ranking (800kg tomato from Nagpur):")
    ranked = get_best_pocket_cash_mandi("tomato", 800, 21.1458, 79.0882)
    for m in ranked:
        rec = " ★" if m.get("recommended") else ""
        print(f"  {m['mandi']}: ₹{m['pocket_cash']} pocket cash{rec}")
