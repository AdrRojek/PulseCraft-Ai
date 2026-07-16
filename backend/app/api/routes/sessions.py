from fastapi import APIRouter, HTTPException

from app.models.session import Session, SessionCreate
from app.services.session_store import session_store

router = APIRouter(prefix="/sessions", tags=["sessions"])


@router.post("", response_model=Session)
def create_session(payload: SessionCreate) -> Session:
    return session_store.create(payload)


@router.get("/{session_id}", response_model=Session)
def get_session(session_id: str) -> Session:
    session = session_store.get(session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="session not found")
    return session

# Lifecycle: create -> stream keypoints -> summarize
