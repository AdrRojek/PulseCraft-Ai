from pydantic import BaseModel, Field


class Keypoint(BaseModel):
    x: float
    y: float
    confidence: float = Field(default=1.0, ge=0.0, le=1.0)


class KeypointFrame(BaseModel):
    t_ms: int = Field(ge=0)
    landmarks: list[Keypoint]


class KeypointBatch(BaseModel):
    session_id: str
    frames: list[KeypointFrame]
