from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.models.database import create_tables
from backend.api import auth, user, harvest, market, spoilage, preservation, chat, middleware

app = FastAPI(
    title="AgriChain API",
    version="1.0.0",
    description="Farm-to-market intelligence platform for Indian farmers",
)

# ── CORS (allow all origins in dev) ─────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Include routers ─────────────────────────────────────────────────────────
app.include_router(auth.router, prefix="/api/v1")
app.include_router(user.router, prefix="/api/v1")
app.include_router(harvest.router, prefix="/api/v1")
app.include_router(market.router, prefix="/api/v1")
app.include_router(spoilage.router, prefix="/api/v1")
app.include_router(preservation.router, prefix="/api/v1")
app.include_router(chat.router, prefix="/api/v1")
app.include_router(middleware.router, prefix="/api/v1")


# ── Startup event ───────────────────────────────────────────────────────────
@app.on_event("startup")
async def startup_event():
    create_tables()


# ── Root endpoint ───────────────────────────────────────────────────────────
@app.get("/")
async def root():
    return {"message": "AgriChain API", "docs": "/docs"}
