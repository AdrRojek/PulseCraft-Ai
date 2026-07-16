from fastapi import APIRouter, UploadFile, File, HTTPException

from app.workers.tasks import analyze_video

router = APIRouter(prefix="/videos", tags=["videos"])


@router.post("/upload")
async def upload_video(session_id: str, file: UploadFile = File(...)) -> dict[str, str]:
    if not file.filename:
        raise HTTPException(status_code=400, detail="missing filename")
    analyze_video.delay(session_id, file.filename)
    return {"session_id": session_id, "filename": file.filename, "status": "queued"}
