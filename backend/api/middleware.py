import datetime

from fastapi import APIRouter, Query, Depends
from sqlalchemy.orm import Session

from backend.models.database import get_db, AdviceHistory, Notification, User

router = APIRouter(tags=["general"])


# ─── Crops ───────────────────────────────────────────────────────────────────

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
                        {"id": "cauliflower", "name": "Cauliflower", "icon_url": "🥦"},
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


# ─── Soil Types ──────────────────────────────────────────────────────────────

@router.get("/soil-types")
async def get_soil_types():
    """Get soil type reference data."""
    return {
        "success": True,
        "data": [
            {"id": "black", "name": "Black Soil (Regur)", "icon_url": "⬛",
             "description": "Rich in calcium, magnesium, potash. Best for cotton, soybean, wheat. Found in Deccan Plateau."},
            {"id": "alluvial", "name": "Alluvial Soil", "icon_url": "🟫",
             "description": "Most fertile soil in India. Rich in potash, phosphoric acid. Best for rice, wheat, sugarcane."},
            {"id": "red", "name": "Red Soil", "icon_url": "🔴",
             "description": "Rich in iron. Porous and friable. Suitable for groundnut, millet, tobacco, pulses."},
            {"id": "laterite", "name": "Laterite Soil", "icon_url": "🟠",
             "description": "High iron and aluminium content. Good for tea, coffee, cashew with proper fertilization."},
            {"id": "sandy", "name": "Sandy Soil", "icon_url": "🟡",
             "description": "Low water retention. Good drainage. Suitable for groundnut, barley, millet."},
            {"id": "clayey", "name": "Clayey Soil", "icon_url": "🔵",
             "description": "High water retention. Rich in organic matter. Good for rice, wheat in wet conditions."},
        ],
    }


# ─── Weather (Real) ─────────────────────────────────────────────────────────

@router.get("/weather")
async def get_weather(lat: float = Query(21.1458), lng: float = Query(79.0882)):
    """Get real weather data from OpenWeatherMap (with fallback)."""
    try:
        from backend.tools.weather import (
            get_current_weather,
            get_weather_forecast,
            detect_heatwave_risk,
        )

        current = get_current_weather(lat, lng)
        forecast = get_weather_forecast(lat, lng)
        heatwave = detect_heatwave_risk(lat, lng)

        return {
            "success": True,
            "data": {
                "current": current,
                "forecast": forecast,
                "heatwave_risk": heatwave,
            },
        }
    except Exception as e:
        return {
            "success": True,
            "data": {
                "current": {"temp_c": 34, "humidity_pct": 65,
                            "description": "Clear sky"},
                "forecast": [],
                "heatwave_risk": {"alert": False},
            },
            "fallback": True,
        }


# ─── Advice History (Real DB) ───────────────────────────────────────────────

@router.get("/advice-history")
async def get_advice_history(db: Session = Depends(get_db)):
    """Get advice history from database."""
    entries = (
        db.query(AdviceHistory)
        .order_by(AdviceHistory.created_at.desc())
        .limit(20)
        .all()
    )

    total_savings = sum(e.savings_rupees or 0 for e in entries)

    return {
        "success": True,
        "data": {
            "total_estimated_savings": total_savings,
            "entries": [
                {
                    "id": e.id,
                    "type": e.type,
                    "recommendation": e.recommendation,
                    "savings_rupees": e.savings_rupees,
                    "followed": e.followed,
                    "created_at": str(e.created_at) if e.created_at else None,
                }
                for e in entries
            ],
        },
    }


# ─── Notifications (Real DB) ────────────────────────────────────────────────

@router.get("/notifications")
async def get_notifications(db: Session = Depends(get_db)):
    """Get notifications from database with dynamic weather alerts."""
    notifications = []

    # Try to add a live weather-based notification
    try:
        from backend.tools.weather import get_current_weather

        weather = get_current_weather(21.1458, 79.0882)
        temp = weather.get("temp_c", 30)
        if temp > 38:
            notifications.append({
                "id": "weather-live",
                "type": "alert",
                "title": "⚠️ Heatwave Alert",
                "body": f"Temperature is {temp}°C. Your crop will spoil faster. Consider selling today or improving storage.",
                "timestamp": datetime.datetime.utcnow().isoformat(),
                "read": False,
            })
    except Exception:
        pass

    # Get stored notifications from DB
    db_notifs = (
        db.query(Notification)
        .order_by(Notification.created_at.desc())
        .limit(10)
        .all()
    )

    for n in db_notifs:
        notifications.append({
            "id": n.id,
            "type": n.type,
            "title": n.title,
            "body": n.body,
            "timestamp": str(n.created_at) if n.created_at else None,
            "read": n.read,
        })

    # Always include base notifications if DB is empty
    if not db_notifs:
        now = datetime.datetime.utcnow()
        notifications.extend([
            {
                "id": "demo-1",
                "type": "price",
                "title": "💰 Tomato prices up ₹3/kg",
                "body": "Wardha Mandi is offering ₹18/kg today, up from ₹15/kg yesterday.",
                "timestamp": (now - datetime.timedelta(hours=2)).isoformat(),
                "read": False,
            },
            {
                "id": "demo-2",
                "type": "harvest",
                "title": "🌾 Good time to harvest",
                "body": "Your tomato crop score is 85. Weather looks clear for the next 3 days.",
                "timestamp": (now - datetime.timedelta(hours=5)).isoformat(),
                "read": True,
            },
            {
                "id": "demo-3",
                "type": "welcome",
                "title": "🎉 Welcome to AgriChain",
                "body": "We help you make more money from your crops. Check your harvest score daily!",
                "timestamp": (now - datetime.timedelta(days=30)).isoformat(),
                "read": True,
            },
        ])

    return {"success": True, "data": notifications}


# ─── Health ──────────────────────────────────────────────────────────────────

@router.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "ok", "version": "1.0.0"}
