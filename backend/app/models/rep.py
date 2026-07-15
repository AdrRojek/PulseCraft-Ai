from pydantic import BaseModel, Field


class RepMetrics(BaseModel):
    mean_concentric_velocity: float = Field(ge=0.0)
    peak_velocity: float = Field(ge=0.0)
    rom_deg: float | None = None


class Rep(BaseModel):
    index: int = Field(ge=0)
    metrics: RepMetrics
