from fastapi import APIRouter

from app.models.recommendation import Recommendation

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("/{session_id}", response_model=list[Recommendation])
def list_recommendations(session_id: str) -> list[Recommendation]:
    return [
        Recommendation(
            title="Brace before descent",
            detail="Maintain rib-over-pelvis alignment on rep 3 sticking region.",
            priority=2,
        )
    ]
