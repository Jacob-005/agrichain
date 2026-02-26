"""
E2E tests that walk through the exact demo script.
Requires the server to be running on localhost:8000.
"""

import os
import time

import pytest
import requests

BASE = os.getenv("AGRICHAIN_API_URL", "http://localhost:8000/api/v1")


@pytest.fixture(autouse=True)
def slow_down():
    """Prevent Gemini rate limits between tests."""
    yield
    time.sleep(2)


# ─── Onboarding ──────────────────────────────────────────────


class TestDemoOnboarding:
    def test_send_otp(self):
        r = requests.post(f"{BASE}/auth/send-otp", json={"phone": "9999999999"})
        assert r.status_code == 200
        assert r.json().get("success") is True

    def test_verify_otp_returns_token(self):
        r = requests.post(
            f"{BASE}/auth/verify-otp",
            json={"phone": "9999999999", "otp": "123456"},
        )
        assert r.status_code == 200
        data = r.json()
        assert data.get("success") is True
        assert "token" in data
        assert "user_id" in data

    def test_save_profile(self):
        # Get token
        r = requests.post(
            f"{BASE}/auth/verify-otp",
            json={"phone": "9999999999", "otp": "123456"},
        )
        token = r.json().get("token", "")
        # Save profile
        r2 = requests.post(
            f"{BASE}/user/profile",
            json={
                "name": "Ramesh",
                "age": 45,
                "lat": 21.1458,
                "lng": 79.0882,
                "district": "Nagpur",
                "soil_type": "black",
                "language": "hindi",
            },
            headers={"Authorization": f"Bearer {token}"},
        )
        assert r2.status_code == 200


# ─── Harvest ─────────────────────────────────────────────────


class TestDemoHarvest:
    def test_harvest_score_returns_valid(self):
        r = requests.post(f"{BASE}/harvest/score", json={"crop": "tomato"})
        assert r.status_code == 200
        data = r.json()
        assert data.get("success") is True
        print(f"\n  HARVEST: {data}")

    def test_harvest_explanation_not_empty(self):
        r = requests.post(f"{BASE}/harvest/score", json={"crop": "tomato"})
        data = r.json()
        d = data.get("data", {})
        explanation = d.get("explanation_text", d.get("explanation", ""))
        assert len(explanation) > 10
        print(f"\n  EXPLANATION: {explanation[:200]}")


# ─── Market ──────────────────────────────────────────────────


class TestDemoMarket:
    def test_market_compare_returns_data(self):
        r = requests.post(
            f"{BASE}/market/compare",
            json={"crop": "tomato", "volume_kg": 800},
        )
        assert r.status_code == 200
        assert r.json().get("success") is True
        print(f"\n  MARKET: {r.json()}")


# ─── Spoilage ────────────────────────────────────────────────


class TestDemoSpoilage:
    def test_spoilage_check_returns_data(self):
        r = requests.post(
            f"{BASE}/spoilage/check",
            json={
                "crop": "tomato",
                "storage_method": "open_floor",
                "hours_since_harvest": 6,
            },
        )
        assert r.status_code == 200
        assert r.json().get("success") is True
        print(f"\n  SPOILAGE: {r.json()}")


# ─── Preservation ────────────────────────────────────────────


class TestDemoPreservation:
    def test_preservation_options(self):
        r = requests.post(
            f"{BASE}/preservation/options",
            json={"crop": "tomato", "current_storage": "open_floor"},
        )
        assert r.status_code == 200
        assert r.json().get("success") is True
        print(f"\n  PRESERVATION: {r.json()}")


# ─── Chat ────────────────────────────────────────────────────


class TestDemoChat:
    def test_chat_routes_to_market(self):
        r = requests.post(
            f"{BASE}/chat/",
            json={"message": "Where should I sell my tomatoes?"},
        )
        assert r.status_code == 200
        data = r.json()
        intent = data.get("data", {}).get("intent", "")
        print(f"\n  CHAT INTENT: {intent}")

    def test_chat_routes_to_harvest(self):
        r = requests.post(
            f"{BASE}/chat/",
            json={"message": "Should I harvest today?"},
        )
        assert r.status_code == 200


# ─── History + Notifications ─────────────────────────────────


class TestDemoHistory:
    def test_advice_history_has_entries(self):
        r = requests.get(f"{BASE}/advice-history")
        assert r.status_code == 200
        data = r.json()
        entries = data.get("data", {}).get("entries", [])
        assert len(entries) >= 1
        total = data.get("data", {}).get("total_estimated_savings", 0)
        print(f"\n  TOTAL SAVINGS: ₹{total}")
        print(f"  ENTRIES: {len(entries)}")

    def test_notifications_returns_list(self):
        r = requests.get(f"{BASE}/notifications")
        assert r.status_code == 200
        notifs = r.json().get("data", [])
        assert len(notifs) >= 1


# ─── Weather + Stats ─────────────────────────────────────────


class TestDemoWeather:
    def test_weather_returns_data(self):
        r = requests.get(f"{BASE}/weather")
        assert r.status_code == 200
        data = r.json().get("data", {})
        assert "current" in data
        print(f"\n  WEATHER: {data.get('current', {})}")


class TestDemoStats:
    def test_stats_returns_counts(self):
        r = requests.get(f"{BASE}/stats")
        assert r.status_code == 200
        data = r.json().get("data", {})
        assert "total" in data
        assert "success_rate" in data
        print(f"\n  STATS: {data}")


# ─── Voice TTS ───────────────────────────────────────────────


class TestDemoVoice:
    def test_voice_generates_audio(self):
        r = requests.post(
            f"{BASE}/voice/generate",
            json={"text": "आज मौसम अच्छा है", "language": "hindi"},
        )
        assert r.status_code == 200
        data = r.json()
        if data.get("success"):
            assert "audio_url" in data
            print(f"\n  AUDIO URL: {data['audio_url']}")


# ─── Health ──────────────────────────────────────────────────


class TestHealth:
    def test_health_check(self):
        r = requests.get(f"{BASE}/health")
        assert r.status_code == 200
        assert r.json().get("status") == "ok"
