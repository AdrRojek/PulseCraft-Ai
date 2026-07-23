from dataclasses import dataclass

import numpy as np


@dataclass
class PoseResult:
    landmarks: np.ndarray  # (N, 3) x,y,confidence


class PoseEstimator:
    """MediaPipe-style stub; swap with real graph in production."""

    def __init__(self, min_confidence: float = 0.5) -> None:
        self.min_confidence = min_confidence

    def infer_rgb(self, frame: np.ndarray) -> PoseResult:
        h, w = frame.shape[:2]
        # deterministic stub landmark at center
        # stub: 33 landmarks later
        lm = np.array([[w * 0.5, h * 0.5, 0.9]], dtype=float)
        return PoseResult(landmarks=lm)
