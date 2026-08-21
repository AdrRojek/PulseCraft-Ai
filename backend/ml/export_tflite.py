"""Export FormScoreRegressor to TFLite via a Keras weight-matched twin."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def export_tflite(
    pt_path: Path = ROOT / "artifacts" / "form_score_model.pt",
    out: Path = ROOT / "artifacts" / "form_score.tflite",
) -> Path:
    """Prefer prebuilt artifact from train_artifacts; otherwise convert."""
    if out.exists() and out.stat().st_size > 100:
        return out
    # Lazy import — conversion environment may differ from API runtime
    from ml.train import export_tflite_from_keras, train_torch

    _, model = train_torch()
    return export_tflite_from_keras(model)


if __name__ == "__main__":
    p = export_tflite()
    print(p, p.stat().st_size)
