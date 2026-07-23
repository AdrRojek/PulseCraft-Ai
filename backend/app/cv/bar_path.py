import numpy as np


def bar_center_from_wrists(left: np.ndarray, right: np.ndarray) -> np.ndarray:
    return (left + right) / 2.0


def trajectory_curvature(path: np.ndarray) -> float:
    if len(path) < 3:
        return 0.0
    v = np.diff(path, axis=0)
    angles = []
    for i in range(1, len(v)):
        a, b = v[i - 1], v[i]
        na, nb = np.linalg.norm(a), np.linalg.norm(b)
        if na < 1e-9 or nb < 1e-9:
            continue
        cos = np.clip(np.dot(a, b) / (na * nb), -1.0, 1.0)
        angles.append(float(np.arccos(cos)))
    return float(np.mean(angles)) if angles else 0.0


def path_length(path: np.ndarray) -> float:
    if len(path) < 2:
        return 0.0
    return float(np.sum(np.linalg.norm(np.diff(path, axis=0), axis=1)))
