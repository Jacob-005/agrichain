# AgriChain — Farm-to-Market Intelligence Platform

## Architecture Overview

AgriChain is a multi-agent AI system that helps Indian farmers make profitable post-harvest decisions. The platform combines real-time weather data, market prices, and crop science into actionable advice delivered through a bilingual (Hindi/English) mobile app.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│  (Hindi/English UI, voice-ready, low-literacy optimized)    │
└──────────────────────┬──────────────────────────────────────┘
                       │ REST API (JSON)
┌──────────────────────▼──────────────────────────────────────┐
│                   FastAPI Backend                            │
│  ┌─────────────┐  ┌──────────────────┐  ┌──────────────┐   │
│  │   Auth API   │  │  Orchestrator    │  │  Middleware   │   │
│  │  JWT + OTP   │  │  Intent Router   │  │ Crops/Soil/  │   │
│  │             │  │  Response Format  │  │ Weather/Notif│   │
│  └─────────────┘  └────────┬─────────┘  └──────────────┘   │
│                            │                                 │
│              ┌─────────────┼────────────────┐               │
│              ▼             ▼                ▼               │
│  ┌──────────────┐ ┌──────────────┐ ┌───────────────┐       │
│  │Harvest Agent │ │Market Agent  │ │Spoilage Agent │       │
│  │Score 0-100   │ │Pocket Cash   │ │Freshness Timer│       │
│  └──────┬───────┘ └──────┬───────┘ └───────┬───────┘       │
│         │                │                  │               │
│  ┌──────▼────────────────▼──────────────────▼───────┐       │
│  │              7 Backend Tools                      │       │
│  │  distance · soil · mandi · weather · spoilage    │       │
│  │  preservation · explanation (Gemini LLM)         │       │
│  └──────────────────────┬───────────────────────────┘       │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────┐       │
│  │              SQLite Database                      │       │
│  │  users · user_crops · advice_history · notifs    │       │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
   OpenWeatherMap   Mandi Data   Google Gemini
   (live weather)  (JSON files)  (explanations)
```

## Agent Architecture

All agents use **LangGraph `create_react_agent`** with **Google Gemini 2.0 Flash**.

| Agent | Purpose | Tools Used |
|-------|---------|-----------|
| **Harvest** | Score 0-100 for harvest readiness | weather, forecast, soil, market, scoring formula |
| **Market** | Rank mandis by "pocket cash" (net revenue) | nearby mandis, temperature, pocket cash calculator |
| **Spoilage** | Predict remaining shelf life | spoilage checker, heatwave detection |
| **Preservation** | Recommend storage methods by ROI | preservation options, benefit calculator, freshness check |

## Database Schema

| Table | Key Fields |
|-------|-----------|
| `users` | id (UUID), phone, name, age, lat, lng, district, soil_type, language |
| `user_crops` | id, user_id (FK), crop_id, status |
| `advice_history` | id, user_id (FK), type, recommendation, savings_rupees, followed |
| `notifications` | id, user_id (FK), title, body, type, read |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/send-otp` | Send OTP to phone |
| POST | `/api/v1/auth/verify-otp` | Verify OTP, get JWT |
| POST | `/api/v1/user/profile` | Create/update profile |
| GET | `/api/v1/user/profile` | Get user profile |
| POST | `/api/v1/harvest/score` | AI harvest score |
| POST | `/api/v1/market/compare` | AI mandi comparison |
| POST | `/api/v1/spoilage/check` | AI spoilage prediction |
| POST | `/api/v1/preservation/options` | AI preservation advice |
| POST | `/api/v1/chat/` | Natural language chat (routes to agent) |
| GET | `/api/v1/weather` | Live weather data |
| GET | `/api/v1/advice-history` | Past recommendations + savings |
| GET | `/api/v1/notifications` | Contextual alerts |
| GET | `/api/v1/crops` | Crop reference data |
| GET | `/api/v1/soil-types` | Soil reference data |
| GET | `/api/v1/health` | Health check |

## Tech Stack

- **Backend**: Python 3.13, FastAPI, SQLAlchemy, SQLite
- **AI**: LangGraph, Google Gemini 2.0 Flash, LangChain
- **Mobile**: Flutter/Dart
- **APIs**: OpenWeatherMap (weather), Google Gemini (explanations)
- **Auth**: JWT (PyJWT), OTP-based

## Folder Structure

```
agrichain/
├── backend/
│   ├── agents/         # 4 LangGraph AI agents
│   ├── api/            # FastAPI route handlers
│   ├── config/         # Settings and env config
│   ├── models/         # SQLAlchemy models
│   ├── orchestrator/   # Intent router + response formatter
│   ├── tools/          # 7 backend tool modules
│   ├── main.py         # FastAPI app entry point
│   └── seed_demo_data.py
├── data/               # JSON data files (crops, mandis, etc.)
├── docs/               # Documentation
├── mobile/             # Flutter app
└── tests/              # pytest test suites
```
