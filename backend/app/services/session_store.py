from __future__ import annotations

import uuid
from datetime import datetime

from app.models.session import Session, SessionCreate, LiftType


class SessionStore:
    def __init__(self) -> None:
        self._sessions: dict[str, Session] = {}

    def create(self, payload: SessionCreate) -> Session:
        sid = str(uuid.uuid4())
        session = Session(id=sid, lift=payload.lift, notes=payload.notes)
        self._sessions[sid] = session
        return session

    def get(self, session_id: str) -> Session | None:
        return self._sessions.get(session_id)

    def list(self) -> list[Session]:
        return sorted(self._sessions.values(), key=lambda s: s.created_at, reverse=True)


session_store = SessionStore()
