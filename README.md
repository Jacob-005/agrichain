
# AgriChain

Farm-to-market intelligence platform for Indian farmers.

## Quick Start (Backend)
=======
# AgriChain — Farm to Market Intelligence

AgriChain is an AI-powered farm-to-market intelligence platform built for 
Indian farmers. It helps farmers make smarter decisions about **when to harvest**, 
**where to sell**, **how to preserve** their crops, and **how much they'll 
actually pocket** after transportation costs — all through a mobile app 
with full Hindi support.

## Tech Stack

| Component       | Technology                | Owner |
|----------------|---------------------------|-------|
| Backend API    | Python / FastAPI           | G     |
| Mobile App     | Flutter / Dart             | M     |
| Data & Tests   | JSON / Pytest              | J     |
| AI Engine      | Google Gemini API          | G     |
| Database       | SQLite (dev) / PostgreSQL  | G     |
| Authentication | OTP-based (phone number)   | G     |

## Quick Start

### Backend


```bash
cd backend
python -m venv venv
<<<<<<< HEAD
venv\Scripts\activate      # Windows
# source venv/bin/activate  # macOS/Linux
pip install -r requirements.txt
cd ..
uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
```

Open http://localhost:8000/docs for Swagger UI.

## Repository Structure

- `backend/` — FastAPI backend (Python)
- `mobile/` — Flutter mobile app
- `data/` — Static data files (crops, soil types, mandi prices)
- `tests/` — Test suites
- `contracts/` — API contract (source of truth)
- `docs/` — Documentation
=======
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

### Run Tests

```bash
# Data validation tests (no backend needed)
pytest tests/test_data/ -v

# API integration tests (backend must be running)
pytest tests/test_api/ -v
```

## Folder Structure

```
agrichain/
├── backend/                # FastAPI backend
│   ├── main.py
│   ├── agents/             # AI agent implementations
│   ├── routers/            # API route handlers
│   ├── models/             # Pydantic data models
│   └── requirements.txt
├── mobile/                 # Flutter mobile app
│   ├── lib/
│   └── pubspec.yaml
├── data/                   # JSON data files
│   ├── crops.json          # 37 crops across 7 categories
│   ├── soil_types.json     # 6 Indian soil types
│   ├── mandi_prices.json   # Market prices for 10+ crops
│   ├── mandi_locations.json # 16 mandis across India
│   ├── spoilage_data.json  # Shelf life by storage & temperature
│   └── preservation_methods.json # Low-cost preservation guides
├── tests/                  # Pytest test suite
│   ├── conftest.py         # Shared test fixtures
│   ├── test_api/           # API integration tests
│   └── test_data/          # Data validation tests
├── docs/                   # Documentation
│   ├── architecture.md     # Technical architecture
│   ├── api_reference.md    # API endpoint reference
│   └── demo_script.md      # Presentation demo script
├── contracts/              # API contracts
│   └── api_contract.yaml
└── README.md
```

## Key Features

- **🌾 Harvest Score** — AI-powered harvest readiness assessment (0-100)
- **💰 Pocket Cash** — Net revenue comparison across mandis (price minus transport)
- **⏳ Spoilage Timer** — Real-time countdown showing crop shelf life
- **🧊 Preservation Guide** — Step-by-step preservation methods (including free options)
- **🇮🇳 Bilingual** — Full Hindi + English support with Devanagari script
- **📊 Savings Tracker** — Cumulative savings from AgriChain recommendations

## Team

| Role                  | Member | Responsibilities                     |
|-----------------------|--------|--------------------------------------|
| Backend Engineer      | G      | FastAPI, agents, database, auth      |
| Mobile Developer      | M      | Flutter app, UI/UX, notifications    |
| Data & Test Engineer  | J      | Data files, test suite, documentation|

## License

MIT
>>>>>>> origin/dev-j
