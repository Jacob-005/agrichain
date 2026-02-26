# AgriChain Live Demo Script (5 Minutes)

## Setup

- Backend running on J's laptop: `uvicorn backend.main:app --host 0.0.0.0 --port 8000`
- App on M's phone/emulator connected to J's IP
- Demo data seeded: `python backend/seed_demo_data.py`

---

## Minute 0-1: Onboarding

> "Meet Ramesh, a tomato farmer from Nagpur."

1. Splash screen → Select **Hindi**
2. Phone: `9999999999` → OTP: `123456`
3. Name: **Ramesh**, Age: **45**, GPS: **Nagpur**
4. Crops: **Tomato**, **Onion** → Soil: **Black** → Home page

---

## Minute 1-2: Harvest Score

> "Every morning, Ramesh checks if today is the right day to harvest."

1. Home screen shows the **harvest score circle** (animated, yellow ~78)
2. Tap **"Why this score?"** → AI explanation in Hindi
3. _"The AI analyzed weather, market supply, and soil moisture to give Ramesh a simple number."_

---

## Minute 2-3: Market Optimizer

> "Ramesh harvests. Where should he sell?"

1. Go to **Market** tab → Tomato → **800 kg** → Find Best Mandi
2. Three mandi cards appear with pocket cash amounts
3. _"Amravati offers ₹22/kg — the highest price. But AgriChain recommends Wardha at ₹15/kg. Why?"_
4. _"Less fuel + less spoilage = more cash in Ramesh's pocket."_ ← **Core value prop**

---

## Minute 3-4: Spoilage Monitor

> "Ramesh can't go to mandi today."

1. Go to **Spoilage** tab → "I Have Harvested" → **Open Floor** storage
2. Timer shows: **"Safe for 47 hours"** (green)
3. Temperature rises → timer turns **yellow** → then **red**
4. _"⚠️ Heatwave alert! Only 8 hours left. Act NOW."_

---

## Minute 4-5: Preservation + Impact

> "How can Ramesh protect his crop?"

1. Go to **Preservation** tab → 3 methods ranked by ROI
2. _"Cooling bin: ₹75 cost, saves ₹1,200. That's 16x ROI."_
3. Show **Advice History** → Total savings: **₹3,900**
4. _"Over 30 days, AgriChain saved Ramesh nearly ₹4,000."_

---

## Closing

> "AgriChain doesn't tell farmers the highest price. It tells them the **most profitable decision**."

---

## Emergency Fallbacks

| If... | Do this |
|-------|---------|
| Agent takes too long | Endpoints return stub data automatically |
| No internet | Weather uses fallback (35°C), agents still work |
| API key missing | Explanation returns template text in Hindi |
| DB empty | Notifications show hardcoded demo items |
