import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

# Load .env from project root
load_dotenv(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env"))


class Settings(BaseSettings):
    GOOGLE_API_KEY: str = ""
    OPENWEATHER_API_KEY: str = ""
    JWT_SECRET: str = "agrichain_secret_key_change_in_prod"
    DATABASE_URL: str = "sqlite:///./agrichain.db"

    class Config:
        env_file = ".env"


settings = Settings()
