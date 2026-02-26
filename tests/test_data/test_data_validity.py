"""
Data Validity Tests
Validate all JSON data files for structure, completeness, and correctness.
"""

import json
import os
import pytest

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "data")


def load_json(filename):
    """Helper to load a JSON data file."""
    filepath = os.path.join(DATA_DIR, filename)
    assert os.path.exists(filepath), f"Data file missing: {filename}"
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)


# ─── crops.json ───────────────────────────────────────────────

class TestCropsJson:
    @pytest.fixture(autouse=True)
    def load_data(self):
        self.data = load_json("crops.json")

    def test_is_valid_json(self):
        """crops.json should be parseable JSON."""
        assert self.data is not None

    def test_has_categories_key(self):
        """crops.json should have a 'categories' key."""
        assert "categories" in self.data

    def test_has_seven_categories(self):
        """crops.json should have all 7 categories."""
        categories = self.data["categories"]
        assert len(categories) == 7
        expected = {"vegetables", "fruits", "grains", "pulses", "spices", "cash_crops", "medicinal"}
        actual = {c["name"] for c in categories}
        assert actual == expected

    def test_total_crops_at_least_30(self):
        """crops.json should have at least 30 crops total."""
        total = sum(len(cat["crops"]) for cat in self.data["categories"])
        assert total >= 30, f"Only {total} crops found, expected >= 30"

    def test_each_crop_has_required_fields(self):
        """Every crop must have id, name_en, and name_hi."""
        for category in self.data["categories"]:
            for crop in category["crops"]:
                assert "id" in crop, f"Crop missing 'id' in {category['name']}"
                assert "name_en" in crop, f"Crop {crop.get('id')} missing 'name_en'"
                assert "name_hi" in crop, f"Crop {crop.get('id')} missing 'name_hi'"

    def test_hindi_names_are_devanagari(self):
        """Hindi names should contain Devanagari characters."""
        for category in self.data["categories"]:
            for crop in category["crops"]:
                name_hi = crop["name_hi"]
                has_devanagari = any("\u0900" <= ch <= "\u097F" for ch in name_hi)
                assert has_devanagari, f"Crop {crop['id']} name_hi '{name_hi}' has no Devanagari chars"


# ─── soil_types.json ──────────────────────────────────────────

class TestSoilTypesJson:
    @pytest.fixture(autouse=True)
    def load_data(self):
        self.data = load_json("soil_types.json")

    def test_is_valid_json(self):
        assert self.data is not None

    def test_has_six_soil_types(self):
        assert len(self.data) == 6

    def test_each_soil_has_required_fields(self):
        required = {"id", "name_en", "name_hi", "water_retention", "fertility", "suitable_crops", "moisture_factor"}
        for soil in self.data:
            for field in required:
                assert field in soil, f"Soil {soil.get('id')} missing '{field}'"

    def test_moisture_factor_is_positive(self):
        for soil in self.data:
            assert soil["moisture_factor"] > 0, f"Soil {soil['id']} has non-positive moisture_factor"


# ─── mandi_prices.json ────────────────────────────────────────

class TestMandiPricesJson:
    @pytest.fixture(autouse=True)
    def load_data(self):
        self.data = load_json("mandi_prices.json")

    def test_is_valid_json(self):
        assert self.data is not None

    def test_has_at_least_10_crops(self):
        assert len(self.data) >= 10, f"Only {len(self.data)} crops found"

    def test_each_crop_has_at_least_3_mandis(self):
        for crop_id, mandis in self.data.items():
            assert len(mandis) >= 3, f"Crop '{crop_id}' has only {len(mandis)} mandis"

    def test_mandi_lat_lng_within_india(self):
        """Latitude 8-37, Longitude 68-97 for India."""
        for crop_id, mandis in self.data.items():
            for m in mandis:
                assert 8 <= m["lat"] <= 37, f"{crop_id}: {m['mandi']} lat {m['lat']} out of India bounds"
                assert 68 <= m["lng"] <= 97, f"{crop_id}: {m['mandi']} lng {m['lng']} out of India bounds"

    def test_prices_are_positive(self):
        for crop_id, mandis in self.data.items():
            for m in mandis:
                assert m["price_per_kg"] > 0, f"{crop_id}: {m['mandi']} has non-positive price"


# ─── mandi_locations.json ─────────────────────────────────────

class TestMandiLocationsJson:
    @pytest.fixture(autouse=True)
    def load_data(self):
        self.data = load_json("mandi_locations.json")

    def test_is_valid_json(self):
        assert self.data is not None

    def test_has_at_least_15_mandis(self):
        assert len(self.data) >= 15, f"Only {len(self.data)} mandis found"

    def test_each_mandi_has_required_fields(self):
        required = {"id", "name", "lat", "lng", "district", "state", "type"}
        for mandi in self.data:
            for field in required:
                assert field in mandi, f"Mandi {mandi.get('id')} missing '{field}'"

    def test_mandi_coordinates_within_india(self):
        for mandi in self.data:
            assert 8 <= mandi["lat"] <= 37, f"Mandi {mandi['id']} lat out of India bounds"
            assert 68 <= mandi["lng"] <= 97, f"Mandi {mandi['id']} lng out of India bounds"


# ─── spoilage_data.json ───────────────────────────────────────

class TestSpoilageDataJson:
    @pytest.fixture(autouse=True)
    def load_data(self):
        self.data = load_json("spoilage_data.json")

    def test_is_valid_json(self):
        assert self.data is not None

    def test_has_at_least_10_crops(self):
        assert len(self.data) >= 10, f"Only {len(self.data)} crops found"

    def test_each_crop_has_four_storage_methods(self):
        expected_methods = {"open_floor", "jute_bags", "plastic_crates", "cold_storage"}
        for crop_id, crop_data in self.data.items():
            methods = set(crop_data["storage_methods"].keys())
            assert methods == expected_methods, f"Crop '{crop_id}' missing methods: {expected_methods - methods}"

    def test_each_method_has_three_temp_bands(self):
        expected_bands = {"below_25", "25_to_35", "above_35"}
        for crop_id, crop_data in self.data.items():
            for method, bands in crop_data["storage_methods"].items():
                actual_bands = set(bands.keys())
                assert actual_bands == expected_bands, f"{crop_id}/{method} missing bands: {expected_bands - actual_bands}"

    def test_shelf_life_values_are_positive(self):
        for crop_id, crop_data in self.data.items():
            for method, bands in crop_data["storage_methods"].items():
                for band, hours in bands.items():
                    assert hours > 0, f"{crop_id}/{method}/{band} has non-positive value: {hours}"

    def test_spoilage_rate_exists(self):
        for crop_id, crop_data in self.data.items():
            assert "spoilage_rate_per_degree_above_35" in crop_data, f"{crop_id} missing spoilage_rate"
            assert crop_data["spoilage_rate_per_degree_above_35"] > 0


# ─── preservation_methods.json ────────────────────────────────

class TestPreservationMethodsJson:
    @pytest.fixture(autouse=True)
    def load_data(self):
        self.data = load_json("preservation_methods.json")

    def test_is_valid_json(self):
        assert self.data is not None

    def test_has_at_least_7_crops(self):
        assert len(self.data) >= 7, f"Only {len(self.data)} crops found"

    def test_each_crop_has_at_least_3_methods(self):
        for crop_id, methods in self.data.items():
            assert len(methods) >= 3, f"Crop '{crop_id}' has only {len(methods)} methods"

    def test_methods_have_cost_and_savings(self):
        for crop_id, methods in self.data.items():
            for m in methods:
                assert "cost_rupees" in m, f"{crop_id}/{m.get('id')} missing cost_rupees"
                assert "saves_rupees" in m, f"{crop_id}/{m.get('id')} missing saves_rupees"

    def test_methods_have_hindi_instructions(self):
        for crop_id, methods in self.data.items():
            for m in methods:
                assert "instructions_hi" in m, f"{crop_id}/{m.get('id')} missing instructions_hi"
                assert len(m["instructions_hi"]) > 10, f"{crop_id}/{m.get('id')} instructions_hi too short"

    def test_methods_have_hindi_names(self):
        for crop_id, methods in self.data.items():
            for m in methods:
                assert "name_hi" in m, f"{crop_id}/{m.get('id')} missing name_hi"
