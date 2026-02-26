# AgriChain

Farm-to-market intelligence platform for Indian farmers.

## Quick Start (Backend)

```bash
cd backend
python -m venv venv
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
