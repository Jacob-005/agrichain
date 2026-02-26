"""
distance.py — Distance, travel time, fuel cost, and transit spoilage calculations.

Pure math utilities. No external API calls. No data file dependencies
(except calculate_transit_spoilage_pct which loads spoilage_data.json).
"""

import json
import math
import os

EARTH_RADIUS_KM = 6371

# Lazy-load spoilage data for transit spoilage calculation
_spoilage_data = None


def _load_spoilage_data():
    global _spoilage_data
    if _spoilage_data is None:
        data_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "data", "spoilage_data.json"
        )
        with open(data_path, encoding="utf-8") as f:
            _spoilage_data = json.load(f)
    return _spoilage_data


def haversine_distance(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """
    Calculate the great-circle distance between two points
    on Earth using the Haversine formula.

    Returns distance in km, rounded to 1 decimal.
    """
    lat1_r, lat2_r = math.radians(lat1), math.radians(lat2)
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)

    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(lat1_r) * math.cos(lat2_r) * math.sin(dlng / 2) ** 2
    )
    c = 2 * math.asin(math.sqrt(a))

    return round(EARTH_RADIUS_KM * c, 1)


def estimate_travel_time(distance_km: float, avg_speed_kmh: float = 30) -> float:
    """
    Estimate travel time in minutes.
    Default speed = 30 km/h (rural India roads).
    """
    return round((distance_km / avg_speed_kmh) * 60, 1)


def estimate_fuel_cost(
    distance_km: float, rate_per_km: float = 8.0, round_trip: bool = True
) -> float:
    """
    Estimate fuel/transport cost in rupees.
    If round_trip is True, doubles the distance.
    """
    effective_distance = distance_km * 2 if round_trip else distance_km
    return round(effective_distance * rate_per_km, 2)


def calculate_transit_spoilage_pct(
    distance_km: float, crop: str, temp_c: float
) -> float:
    """
    Estimate the percentage of crop spoiled during transit.

    Uses open_floor storage assumption (crops on a truck bed).
    Caps at 50% maximum.
    Returns default 5.0 if crop data not found.
    """
    try:
        data = _load_spoilage_data()
        crop_lower = crop.lower()
        if crop_lower not in data:
            return 5.0

        crop_data = data[crop_lower]

        # Determine temperature band
        if temp_c < 25:
            temp_band = "below_25"
        elif temp_c <= 35:
            temp_band = "25_to_35"
        else:
            temp_band = "above_35"

        total_safe_hours = crop_data["storage_methods"]["open_floor"][temp_band]

        # Transit hours at 30 km/h average
        transit_hours = distance_km / 30.0

        spoilage_pct = (transit_hours / total_safe_hours) * 100

        return min(round(spoilage_pct, 1), 50.0)

    except Exception:
        return 5.0


if __name__ == "__main__":
    print("=== Distance Tool Self-Test ===")

    d = haversine_distance(21.1458, 79.0882, 20.9374, 77.7796)
    print(f"Nagpur → Amravati: {d} km")

    t = estimate_travel_time(150)
    print(f"Travel time for 150 km: {t} minutes")

    c = estimate_fuel_cost(100, round_trip=True)
    print(f"Fuel cost round trip 100 km: ₹{c}")

    s = calculate_transit_spoilage_pct(200, "tomato", 38)
    print(f"Transit spoilage (tomato, 200km, 38°C): {s}%")
