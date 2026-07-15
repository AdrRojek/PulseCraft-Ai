from pydantic import BaseModel


class Recommendation(BaseModel):
    title: str
    detail: str
    priority: int = 1
