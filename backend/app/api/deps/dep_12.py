"""FastAPI dependency stub 12."""

from fastapi import Header


def require_client_id(x_client_id: str | None = Header(default=None)) -> str:
    return x_client_id or "anonymous"
