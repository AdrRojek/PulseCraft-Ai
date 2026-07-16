from app.workers.celery_app import celery_app


@celery_app.task(name="app.workers.tasks.analyze_video")
def analyze_video(session_id: str, object_key: str) -> dict[str, str]:
    return {"session_id": session_id, "object_key": object_key, "status": "analyzed"}
