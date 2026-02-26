"""
preservation.py — Preservation method lookup with ROI calculation.

Loads preservation_methods.json. Integrates with spoilage tool for benefit analysis.
"""

import json
import os

from backend.tools.spoilage import predict_remaining_hours

DATA_PATH = os.path.join(
    os.path.dirname(__file__), "..", "..", "data", "preservation_methods.json"
)

with open(DATA_PATH, encoding="utf-8") as f:
    PRESERVATION_DATA = json.load(f)


def get_preservation_options(
    crop: str, current_storage: str = "open_floor"
) -> list:
    """
    Get preservation options for a crop, sorted by ROI (best first).
    Excludes the current storage method from recommendations.
    """
    crop_lower = crop.lower().strip()

    if crop_lower not in PRESERVATION_DATA:
        return []

    methods = PRESERVATION_DATA[crop_lower]
    results = []

    for m in methods:
        # Skip if this is the current storage method
        if m.get("id", "").lower() == current_storage.lower():
            continue

        entry = dict(m)  # copy

        cost = m.get("cost_rupees", 0)
        saves = m.get("saves_rupees", 0)

        if cost == 0:
            entry["roi"] = 9999  # free is always best
        elif cost > 0:
            entry["roi"] = round(saves / cost, 1)
        else:
            entry["roi"] = 0

        results.append(entry)

    # Sort by ROI descending (free/highest ROI first)
    results.sort(key=lambda x: x["roi"], reverse=True)
    return results


def calculate_preservation_benefit(
    crop: str, method_id: str, current_storage: str, temp_c: float
) -> dict:
    """
    Calculate the benefit of upgrading from current_storage to method_id.

    Compares remaining hours between the two methods and computes ROI.
    """
    # Get remaining hours with current method
    current_result = predict_remaining_hours(crop, current_storage, temp_c, 0)
    if "error" in current_result:
        return current_result

    current_remaining = current_result["remaining_hours"]

    # For the new method, we need to map method_id to a storage_method
    # In our data model, preservation methods suggest upgrades
    # The benefit is measured by the extra_days field from the method
    crop_lower = crop.lower().strip()
    methods = PRESERVATION_DATA.get(crop_lower, [])

    method_info = None
    for m in methods:
        if m.get("id", "").lower() == method_id.lower():
            method_info = m
            break

    if method_info is None:
        return {"error": f"Method '{method_id}' not found for crop '{crop}'"}

    cost = method_info.get("cost_rupees", 0)
    saves = method_info.get("saves_rupees", 0)
    extra_days = method_info.get("extra_days", 0)
    extra_hours = extra_days * 24

    new_remaining = current_remaining + extra_hours

    if cost == 0:
        roi_value = 9999
    elif cost > 0:
        roi_value = round(saves / cost, 1)
    else:
        roi_value = 0

    return {
        "crop": crop,
        "current_method": current_storage,
        "new_method": method_id,
        "current_remaining_hours": current_remaining,
        "new_remaining_hours": round(new_remaining, 1),
        "extra_hours_gained": round(extra_hours, 1),
        "extra_days_gained": extra_days,
        "cost_rupees": cost,
        "value_saved_rupees": saves,
        "roi": roi_value,
        "recommendation": "Worth it" if roi_value > 1 else "Consider alternatives",
    }


if __name__ == "__main__":
    print("=== Preservation Tool Self-Test ===")

    options = get_preservation_options("tomato", current_storage="open_floor")
    print(f"Tomato options (current: open_floor):")
    for o in options:
        print(f"  {o['name_en']}: ₹{o['cost_rupees']}, ROI={o['roi']}")

    print(f"\nBenefit of upgrading to ZECC:")
    benefit = calculate_preservation_benefit("tomato", "zecc", "open_floor", 32)
    for k, v in benefit.items():
        print(f"  {k}: {v}")
