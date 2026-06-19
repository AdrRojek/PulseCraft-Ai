from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "PulseCraft AI"
    redis_url: str = "redis://localhost:6379/0"
    jwt_secret: str = "dev-only-change-me"
    model_path: str = "artifacts/form_score_model.pt"
    cors_origins: list[str] = ["*"]

    class Config:
        env_prefix = "PULSE_"

settings = Settings()
