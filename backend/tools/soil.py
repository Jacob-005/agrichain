"""
soil.py — Soil properties lookup from soil_types.json.

Pure data lookup. No external APIs.
"""

import json
import os

DATA_PATH = os.path.join(
    os.path.dirname(__file__), "..", "..", "data", "soil_types.json"
)

with open(DATA_PATH, encoding="utf-8") as f:
    SOIL_DATA = json.load(f)


def get_soil_properties(soil_type: str) -> dict:
    """
    Look up soil properties by ID (case-insensitive).
    Returns the full soil properties dict, or an error dict if not found.
    """
    soil_lower = soil_type.lower().strip()
    for soil in SOIL_DATA:
        if soil["id"].lower() == soil_lower:
            return soil
    return {"error": f"Unknown soil type: {soil_type}"}


def get_moisture_factor(soil_type: str) -> float:
    """
    Get the moisture factor for a soil type.
    Returns 1.0 as default if soil type not found.
    """
    props = get_soil_properties(soil_type)
    return props.get("moisture_factor", 1.0)


def get_suitable_crops(soil_type: str) -> list:
    """
    Get the list of suitable crops for a soil type.
    Returns empty list if soil type not found.
    """
    props = get_soil_properties(soil_type)
    return props.get("suitable_crops", [])


if __name__ == "__main__":
    print("=== Soil Tool Self-Test ===")

    for sid in ["black", "alluvial", "red", "laterite", "sandy", "clayey"]:
        props = get_soil_properties(sid)
        mf = props.get("moisture_factor", "N/A")
        print(f"{sid}: moisture_factor={mf}, crops={props.get('suitable_crops', [])}")

    print(f"\nInvalid: {get_soil_properties('martian_soil')}")
