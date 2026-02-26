from fastapi import APIRouter, Query

router = APIRouter(tags=["general"])


# ── Crops ───────────────────────────────────────────────────────────────────

@router.get("/crops")
async def get_crops():
    """Get all available crops grouped by category."""
    return {
        "success": True,
        "data": {
            "categories": [
                {
                    "name": "Vegetables",
                    "crops": [
                        {"id": "tomato", "name": "Tomato", "icon_url": "🍅"},
                        {"id": "onion", "name": "Onion", "icon_url": "🧅"},
                        {"id": "potato", "name": "Potato", "icon_url": "🥔"},
                        {"id": "brinjal", "name": "Brinjal", "icon_url": "🍆"},
                        {"id": "okra", "name": "Okra (Bhindi)", "icon_url": "🌿"},
                    ],
                },
                {
                    "name": "Fruits",
                    "crops": [
                        {"id": "mango", "name": "Mango", "icon_url": "🥭"},
                        {"id": "banana", "name": "Banana", "icon_url": "🍌"},
                        {"id": "guava", "name": "Guava", "icon_url": "🍈"},
                        {"id": "papaya", "name": "Papaya", "icon_url": "🍈"},
                    ],
                },
                {
                    "name": "Cereals",
                    "crops": [
                        {"id": "rice", "name": "Rice", "icon_url": "🌾"},
                        {"id": "wheat", "name": "Wheat", "icon_url": "🌾"},
                        {"id": "maize", "name": "Maize", "icon_url": "🌽"},
                    ],
                },
                {
                    "name": "Pulses (Dal)",
                    "crops": [
                        {"id": "toor_dal", "name": "Toor Dal", "icon_url": "🫘"},
                        {"id": "chana_dal", "name": "Chana Dal", "icon_url": "🫘"},
                        {"id": "moong_dal", "name": "Moong Dal", "icon_url": "🫘"},
                        {"id": "urad_dal", "name": "Urad Dal", "icon_url": "🫘"},
                    ],
                },
                {
                    "name": "Spices",
                    "crops": [
                        {"id": "turmeric", "name": "Turmeric (Haldi)", "icon_url": "🟡"},
                        {"id": "chilli", "name": "Chilli", "icon_url": "🌶️"},
                        {"id": "coriander", "name": "Coriander", "icon_url": "🌿"},
                    ],
                },
                {
                    "name": "Cash Crops",
                    "crops": [
                        {"id": "cotton", "name": "Cotton", "icon_url": "☁️"},
                        {"id": "sugarcane", "name": "Sugarcane", "icon_url": "🎋"},
                        {"id": "soybean", "name": "Soybean", "icon_url": "🫘"},
                    ],
                },
                {
                    "name": "Oilseeds",
                    "crops": [
                        {"id": "groundnut", "name": "Groundnut", "icon_url": "🥜"},
                        {"id": "mustard", "name": "Mustard", "icon_url": "🌻"},
                        {"id": "sunflower", "name": "Sunflower", "icon_url": "🌻"},
                    ],
                },
            ]
        },
    }


# ── Soil Types ──────────────────────────────────────────────────────────────

@router.get("/soil-types")
async def get_soil_types():
    """Get soil type reference data."""
    return {
        "success": True,
        "data": [
            {
                "id": "black",
                "name": "Black Soil (Regur)",
                "icon_url": "⬛",
                "description": "Rich in calcium, magnesium, potash. Best for cotton, soybean, wheat. Found in Deccan Plateau.",
            },
            {
                "id": "alluvial",
                "name": "Alluvial Soil",
                "icon_url": "🟫",
                "description": "Most fertile soil in India. Rich in potash, phosphoric acid. Best for rice, wheat, sugarcane.",
            },
            {
                "id": "red",
                "name": "Red Soil",
                "icon_url": "🔴",
                "description": "Rich in iron. Porous and friable. Suitable for groundnut, millet, tobacco, pulses.",
            },
            {
                "id": "laterite",
                "name": "Laterite Soil",
                "icon_url": "🟠",
                "description": "High iron and aluminium content. Good for tea, coffee, cashew with proper fertilization.",
            },
            {
                "id": "sandy",
                "name": "Sandy Soil",
                "icon_url": "🟡",
                "description": "Low water retention. Good drainage. Suitable for groundnut, barley, millet.",
            },
            {
                "id": "clayey",
                "name": "Clayey Soil",
                "icon_url": "🔵",
                "description": "High water retention. Rich in organic matter. Good for rice, wheat in wet conditions.",
            },
        ],
    }


# ── Weather ─────────────────────────────────────────────────────────────────

@router.get("/weather")
async def get_weather(lat: float = Query(...), lng: float = Query(...)):
    """Get weather data (stub with mock Nagpur weather)."""
    return {
        "success": True,
        "data": {
            "temp_c": 35.0,
            "humidity_pct": 45,
            "description": "Partly cloudy",
            "forecast": [
                {"day": "Today", "temp_c": 35.0, "humidity_pct": 45, "description": "Partly cloudy"},
                {"day": "Tomorrow", "temp_c": 37.0, "humidity_pct": 40, "description": "Sunny"},
                {"day": "Day After", "temp_c": 33.0, "humidity_pct": 60, "description": "Light rain expected"},
            ],
        },
    }


# ── Advice History ──────────────────────────────────────────────────────────

@router.get("/advice-history")
async def get_advice_history():
    """Get advice history (stub with mock data)."""
    return {
        "success": True,
        "data": [
            {
                "date": "2025-02-20",
                "type": "harvest",
                "recommendation": "Wait 2 days before selling tomatoes — prices will rise.",
                "followed": True,
                "savings_rupees": 1200.0,
            },
            {
                "date": "2025-02-15",
                "type": "market",
                "recommendation": "Sell onions at Kalamna Mandi instead of Hinganghat.",
                "followed": True,
                "savings_rupees": 800.0,
            },
            {
                "date": "2025-02-10",
                "type": "preservation",
                "recommendation": "Use wet jute bags for brinjal storage.",
                "followed": False,
                "savings_rupees": 0.0,
            },
        ],
    }


# ── Notifications ───────────────────────────────────────────────────────────

@router.get("/notifications")
async def get_notifications():
    """Get user notifications (stub with mock data)."""
    return {
        "success": True,
        "data": [
            {
                "id": "notif-001",
                "title": "Price Alert: Tomato 🍅",
                "body": "Tomato prices at Kalamna Mandi rose by ₹3/kg today. Good time to sell!",
                "type": "price_alert",
                "timestamp": "2025-02-26T10:00:00Z",
                "read": False,
            },
            {
                "id": "notif-002",
                "title": "Weather Warning ⚡",
                "body": "Heavy rain expected in Nagpur district tomorrow. Harvest your crop today.",
                "type": "weather_alert",
                "timestamp": "2025-02-25T18:00:00Z",
                "read": True,
            },
        ],
    }


# ── Health ──────────────────────────────────────────────────────────────────

@router.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "ok", "version": "1.0.0"}
