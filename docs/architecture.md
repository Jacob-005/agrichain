# AgriChain Technical Architecture

## Overview

AgriChain is a **farm-to-market intelligence platform** designed for Indian 
farmers. It provides real-time harvest assessment, mandi (market) price 
comparison, crop spoilage prediction, and preservation guidance — all through 
a mobile-first interface with bilingual (Hindi + English) support.

The platform uses an **AI-agent architecture** where specialized agents handle 
distinct agricultural decision-making domains, orchestrated by a central 
coordinator.

## Tech Stack

| Layer        | Technology             | Purpose                            |
|-------------|------------------------|------------------------------------|
| Mobile App  | Flutter (Dart)         | Cross-platform farmer interface    |
| Backend API | Python / FastAPI       | REST API + Agent orchestration     |
| AI/LLM      | Google Gemini API      | Natural language + reasoning       |
| Database    | SQLite (dev) / PostgreSQL (prod) | User data, history       |
| Data Files  | JSON                   | Crop, mandi, spoilage datasets     |
| Auth        | OTP-based (SMS)        | Phone number authentication        |
| Hosting     | TBD                    | Cloud deployment                   |

## System Diagram

```
┌──────────────────────────────────────────────────────────┐
│                    MOBILE APP (Flutter)                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐  │
│  │Onboarding│ │ Harvest  │ │  Market  │ │Preservation│  │
│  │  Screen  │ │  Score   │ │ Compare  │ │  Options   │  │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └─────┬──────┘  │
│       └─────────────┴────────────┴─────────────┘         │
│                         │ HTTP/REST                       │
└─────────────────────────┼────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────┐
│                  BACKEND API (FastAPI)                    │
│  ┌─────────┐ ┌──────────────┐ ┌───────────────────────┐  │
│  │  Auth   │ │   Router     │ │   Agent Orchestrator  │  │
│  │  (OTP)  │ │  /api/v1/*   │ │   (Coordinator)       │  │
│  └─────────┘ └──────┬───────┘ └───────────┬───────────┘  │
│                     │                     │               │
│  ┌──────────────────┴─────────────────────┴────────────┐  │
│  │                  AGENT LAYER                        │  │
│  │  ┌────────┐ ┌────────┐ ┌──────────┐ ┌───────────┐  │  │
│  │  │Harvest │ │Market  │ │Spoilage  │ │Preservation│  │  │
│  │  │ Agent  │ │ Agent  │ │  Agent   │ │  Agent     │  │  │
│  │  └───┬────┘ └───┬────┘ └────┬─────┘ └─────┬─────┘  │  │
│  └──────┼──────────┼───────────┼──────────────┼────────┘  │
│         ▼          ▼           ▼              ▼           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              DATA LAYER (JSON Files)                 │  │
│  │  crops.json │ mandi_prices.json │ spoilage_data.json │  │
│  │  soil_types.json │ mandi_locations.json              │  │
│  │  preservation_methods.json                           │  │
│  └──────────────────────────────────────────────────────┘  │
│         │                                                 │
│         ▼                                                 │
│  ┌──────────────┐  ┌─────────────────────┐               │
│  │   Database   │  │  External APIs      │               │
│  │  (SQLite)    │  │  - Gemini LLM       │               │
│  │  users,      │  │  - Weather API      │               │
│  │  history     │  │  - Agmarknet (TODO) │               │
│  └──────────────┘  └─────────────────────┘               │
└──────────────────────────────────────────────────────────┘
```

## Agent Architecture

AgriChain uses a multi-agent system where each agent is a specialized tool:

| Agent         | Purpose                                    | Input                           | Output                          |
|---------------|--------------------------------------------|---------------------------------|---------------------------------|
| HarvestAgent  | Score harvest readiness (0-100)            | crop, soil, weather, quantity   | Score + explanation             |
| MarketAgent   | Compare mandi prices, compute pocket cash  | crop, quantity, location        | Ranked mandis with net revenue  |
| SpoilageAgent | Predict remaining shelf life               | crop, storage, temp, time       | Hours remaining + urgency       |
| PreservationAgent | Suggest preservation methods by cost   | crop, budget                    | Ranked methods with savings     |

### Pocket Cash Concept

The MarketAgent computes "pocket cash" — the net revenue after subtracting 
transportation costs. A farther mandi may offer higher ₹/kg but lower net 
revenue after transport, making a closer mandi the better choice.

## API Endpoints Summary

| Method | Endpoint                | Auth | Description                  |
|--------|------------------------|------|------------------------------|
| GET    | /health                | No   | Health check                 |
| POST   | /auth/send-otp         | No   | Send OTP to phone            |
| POST   | /auth/verify-otp       | No   | Verify OTP, get token        |
| POST   | /harvest/score         | Yes  | Get harvest readiness score  |
| POST   | /market/compare        | Yes  | Compare mandi prices         |
| POST   | /spoilage/check        | Yes  | Check spoilage timer         |
| POST   | /preservation/options  | Yes  | Get preservation methods     |

## Data Models

### Crop
```json
{
  "id": "tomato",
  "name_en": "Tomato",
  "name_hi": "टमाटर",
  "icon": "🍅",
  "category": "vegetables"
}
```

### Mandi Price Entry
```json
{
  "mandi": "Nagpur APMC",
  "price_per_kg": 18,
  "lat": 21.1458,
  "lng": 79.0882,
  "district": "Nagpur",
  "state": "Maharashtra",
  "last_updated": "2026-02-26"
}
```

### Spoilage Data
```json
{
  "spoilage_rate_per_degree_above_35": 0.08,
  "storage_methods": {
    "open_floor": { "below_25": 72, "25_to_35": 48, "above_35": 24 }
  }
}
```

## External APIs Used

| API             | Provider     | Purpose                          | Status  |
|-----------------|-------------|----------------------------------|---------|
| Gemini API      | Google       | LLM reasoning for agents         | Active  |
| Weather API     | OpenWeather  | Temperature/humidity data         | TODO    |
| Agmarknet       | Govt. India  | Live mandi prices                | TODO    |

## Folder Structure

```
agrichain/
├── backend/              # Python FastAPI backend (Owner: G)
│   ├── main.py
│   ├── agents/           # AI agent implementations
│   ├── routers/          # API route handlers
│   ├── models/           # Pydantic models
│   └── requirements.txt
├── mobile/               # Flutter mobile app (Owner: M)
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
├── data/                 # JSON data files (Owner: J)
│   ├── crops.json
│   ├── soil_types.json
│   ├── mandi_prices.json
│   ├── mandi_locations.json
│   ├── spoilage_data.json
│   └── preservation_methods.json
├── tests/                # Test suite (Owner: J)
│   ├── conftest.py
│   ├── test_api/
│   └── test_data/
├── docs/                 # Documentation (Owner: J)
│   ├── architecture.md
│   ├── api_reference.md
│   └── demo_script.md
├── contracts/            # API contracts (Shared)
│   └── api_contract.yaml
└── README.md
```
