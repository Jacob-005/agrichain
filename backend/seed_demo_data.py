"""
Seed the database with demo data for AgriChain presentation.

Creates demo farmer "Ramesh Patil" with 30 days of advice history
and sample notifications.

Run: python backend/seed_demo_data.py
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from datetime import datetime, timedelta

from backend.models.database import (
    engine,
    Base,
    SessionLocal,
    User,
    UserCrop,
    AdviceHistory,
    Notification,
    generate_uuid,
)


def seed():
    # Create all tables
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    # Check if demo user already exists
    existing = db.query(User).filter(User.phone == "9999999999").first()
    if existing:
        print("Demo data already exists. Skipping.")
        db.close()
        return

    # ── Demo user: Ramesh Patil ──────────────────────────────
    user = User(
        id=generate_uuid(),
        phone="9999999999",
        name="Ramesh Patil",
        age=45,
        lat=21.1458,
        lng=79.0882,
        district="Nagpur",
        soil_type="black",
        language="hindi",
    )
    db.add(user)
    db.flush()

    # ── User crops ───────────────────────────────────────────
    for crop_id in ["tomato", "onion"]:
        db.add(UserCrop(
            id=generate_uuid(),
            user_id=user.id,
            crop_id=crop_id,
            status="growing",
        ))

    # ── Advice history (30 days) ─────────────────────────────
    now = datetime.utcnow()
    advice_entries = [
        AdviceHistory(
            id=generate_uuid(),
            user_id=user.id,
            type="harvest",
            recommendation="Harvest score 82/100. Weather clear, prices stable at ₹18/kg. Good time to harvest your tomatoes.",
            savings_rupees=500,
            followed=True,
            created_at=now - timedelta(days=28),
        ),
        AdviceHistory(
            id=generate_uuid(),
            user_id=user.id,
            type="market",
            recommendation="Wardha Mandi recommended. ₹15/kg but pocket cash ₹11,508 vs Amravati ₹11,200. Saved ₹308 on fuel and spoilage.",
            savings_rupees=1200,
            followed=True,
            created_at=now - timedelta(days=25),
        ),
        AdviceHistory(
            id=generate_uuid(),
            user_id=user.id,
            type="spoilage",
            recommendation="⚠️ Only 8 hours remaining for tomatoes in open floor storage. Temperature 39°C accelerating spoilage.",
            savings_rupees=300,
            followed=True,
            created_at=now - timedelta(days=20),
        ),
        AdviceHistory(
            id=generate_uuid(),
            user_id=user.id,
            type="preservation",
            recommendation="Wet jute bag covering recommended (FREE). Extends freshness by 18 hours. Saves approximately ₹500 in crop loss.",
            savings_rupees=500,
            followed=True,
            created_at=now - timedelta(days=18),
        ),
        AdviceHistory(
            id=generate_uuid(),
            user_id=user.id,
            type="harvest",
            recommendation="Harvest score 45/100. Rain expected tomorrow, prices dropping. Wait 3-4 days.",
            savings_rupees=None,
            followed=True,
            created_at=now - timedelta(days=14),
        ),
        AdviceHistory(
            id=generate_uuid(),
            user_id=user.id,
            type="market",
            recommendation="Nagpur APMC recommended today. Prices up to ₹22/kg due to low supply. Pocket cash ₹14,200.",
            savings_rupees=800,
            followed=False,
            created_at=now - timedelta(days=10),
        ),
        AdviceHistory(
            id=generate_uuid(),
            user_id=user.id,
            type="harvest",
            recommendation="Harvest score 91/100. Excellent conditions — clear weather, rising prices at ₹20/kg, soil moisture optimal.",
            savings_rupees=600,
            followed=True,
            created_at=now - timedelta(days=5),
        ),
        AdviceHistory(
            id=generate_uuid(),
            user_id=user.id,
            type="spoilage",
            recommendation="Tomatoes safe for 52 more hours in jute bag storage. Temperature stable at 32°C. No rush to sell.",
            savings_rupees=None,
            followed=True,
            created_at=now - timedelta(days=2),
        ),
    ]

    for entry in advice_entries:
        db.add(entry)

    # ── Notifications ────────────────────────────────────────
    notifications = [
        Notification(
            id=generate_uuid(),
            user_id=user.id,
            title="💰 Tomato prices up ₹3/kg",
            body="Wardha Mandi is offering ₹18/kg today, up from ₹15/kg yesterday.",
            type="price",
            read=False,
            created_at=now - timedelta(hours=2),
        ),
        Notification(
            id=generate_uuid(),
            user_id=user.id,
            title="🌾 Good time to harvest",
            body="Your tomato crop score is 85. Weather looks clear for the next 3 days.",
            type="harvest",
            read=True,
            created_at=now - timedelta(hours=5),
        ),
        Notification(
            id=generate_uuid(),
            user_id=user.id,
            title="🎉 Welcome to AgriChain",
            body="We help you make more money from your crops. Check your harvest score daily!",
            type="welcome",
            read=True,
            created_at=now - timedelta(days=30),
        ),
    ]

    for n in notifications:
        db.add(n)

    db.commit()

    total = sum(e.savings_rupees or 0 for e in advice_entries)
    print(f"✅ Demo data seeded successfully!")
    print(f"   User: {user.name} (phone: {user.phone})")
    print(f"   Crops: tomato, onion")
    print(f"   Advice entries: {len(advice_entries)}")
    print(f"   Notifications: {len(notifications)}")
    print(f"   Total estimated savings: ₹{total}")

    db.close()


if __name__ == "__main__":
    seed()
