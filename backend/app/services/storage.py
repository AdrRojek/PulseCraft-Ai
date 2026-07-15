from pathlib import Path

from app.models.keypoints import KeypointBatch


class StorageService:
    def __init__(self, root: str = "data/uploads") -> None:
        self.root = Path(root)
        self.root.mkdir(parents=True, exist_ok=True)

    def save_keypoints(self, batch: KeypointBatch) -> str:
        path = self.root / f"{batch.session_id}_keypoints.json"
        path.write_text(batch.model_dump_json(indent=2), encoding="utf-8")
        return str(path)


storage_service = StorageService()
