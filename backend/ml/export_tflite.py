"""TFLite export path (placeholder + documented real pipeline).

Real export options:
  1) PyTorch -> ONNX -> TensorFlow -> TFLite
  2) PyTorch -> ai-edge-torch direct conversion

This script writes a placeholder `.tflite` text marker and conversion log.
"""
from pathlib import Path


def export_tflite(onnx_path: Path = Path("artifacts/form_score.onnx"), out: Path = Path("artifacts/form_score.tflite")) -> Path:
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("PLACEHOLDER_TFLITE_BLOB\nReplace via onnx2tf + tflite_convert.\n", encoding="utf-8")
    log = out.with_suffix(".export.log")
    log.write_text(f"stub export from {onnx_path}\n", encoding="utf-8")
    return out


if __name__ == "__main__":
    p = export_tflite()
    print(f"Wrote placeholder {p}")
