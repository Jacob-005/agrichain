import uuid
from datetime import datetime

from sqlalchemy import create_engine, Column, String, Integer, Float, Boolean, Text, DateTime, ForeignKey
from sqlalchemy.orm import sessionmaker, declarative_base, relationship

from backend.config.settings import settings

engine = create_engine(
    settings.DATABASE_URL,
    connect_args={"check_same_thread": False}  # SQLite specific
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def generate_uuid():
    return str(uuid.uuid4())


# ── Models ──────────────────────────────────────────────────────────────────

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=generate_uuid)
    phone = Column(String, unique=True, nullable=False)
    name = Column(String, nullable=True)
    age = Column(Integer, nullable=True)
    lat = Column(Float, nullable=True)
    lng = Column(Float, nullable=True)
    district = Column(String, nullable=True)
    soil_type = Column(String, nullable=True)
    language = Column(String, default="hindi")
    created_at = Column(DateTime, default=datetime.utcnow)

    crops = relationship("UserCrop", back_populates="user")
    advice_history = relationship("AdviceHistory", back_populates="user")
    notifications = relationship("Notification", back_populates="user")


class UserCrop(Base):
    __tablename__ = "user_crops"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    crop_id = Column(String, nullable=False)
    status = Column(String, default="growing")
    added_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="crops")


class AdviceHistory(Base):
    __tablename__ = "advice_history"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    type = Column(String, nullable=False)
    recommendation = Column(Text, nullable=False)
    followed = Column(Boolean, nullable=True, default=None)
    savings_rupees = Column(Float, nullable=True, default=None)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="advice_history")


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    body = Column(Text, nullable=False)
    type = Column(String, nullable=False)
    read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="notifications")


# ── Helpers ─────────────────────────────────────────────────────────────────

def create_tables():
    Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
