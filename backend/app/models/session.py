from datetime import datetime
from enum import Enum
from pydantic import BaseModel, Field


class LiftType(str, Enum):
    squat = "squat"
    bench = "bench"
    deadlift = "deadlift"


class SessionCreate(BaseModel):
    lift: LiftType
    notes: str | None = None


class Session(BaseModel):
    id: str
    lift: LiftType
    created_at: datetime = Field(default_factory=datetime.utcnow)
    notes: str | None = None

class SessionDetail(Session):
    reps: list["Rep"] = []


from app.models.rep import Rep  # noqa: E402

SessionDetail.model_rebuild()
