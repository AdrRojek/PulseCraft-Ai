import numpy as np

from app.biomechanics.velocity import velocity_1d


def detect_sticking_points(positions: np.ndarray, dt: float, threshold: float = 0.15) -> list[int]:
    v = velocity_1d(positions, dt)
    v_norm = v / (np.max(v) + 1e-9)
    indices: list[int] = []
    for i in range(1, len(v_norm) - 1):
        if v_norm[i] < threshold and v_norm[i] < v_norm[i - 1] and v_norm[i] < v_norm[i + 1]:
            indices.append(i)
    return indices
