from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.models.keypoints import KeypointBatch
from app.services.storage import storage_service

router = APIRouter(tags=["websocket"])


class ConnectionManager:
    def __init__(self) -> None:
        self.active: dict[str, WebSocket] = {}

    async def connect(self, session_id: str, ws: WebSocket) -> None:
        await ws.accept()
        self.active[session_id] = ws

    def disconnect(self, session_id: str) -> None:
        self.active.pop(session_id, None)

    async def push(self, session_id: str, payload: dict) -> None:
        ws = self.active.get(session_id)
        if ws is not None:
            await ws.send_json(payload)


manager = ConnectionManager()


@router.websocket("/ws/sessions/{session_id}/keypoints")
async def keypoints_sync(session_id: str, websocket: WebSocket) -> None:
    await manager.connect(session_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            batch = KeypointBatch.model_validate(data)
            storage_service.save_keypoints(batch)
            await manager.push(session_id, {"type": "ack", "frames": len(batch.frames)})
    except WebSocketDisconnect:
        manager.disconnect(session_id)
