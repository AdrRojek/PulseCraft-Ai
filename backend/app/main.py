from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.routes import health, sessions, videos, recommendations, ws

app = FastAPI(title=settings.app_name, openapi_tags=[{"name": "health"}, {"name": "sessions"}])
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(health.router)
app.include_router(sessions.router)
app.include_router(videos.router)
app.include_router(recommendations.router)
app.include_router(ws.router)
