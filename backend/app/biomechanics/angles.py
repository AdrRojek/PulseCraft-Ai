import numpy as np

from app.biomechanics.math_helpers import unit_vector


def angle_at_joint(a: np.ndarray, b: np.ndarray, c: np.ndarray) -> float:
    """Angle ABC in degrees (b is vertex)."""
    ba = unit_vector(b, a)
    bc = unit_vector(b, c)
    cos = float(np.clip(np.dot(ba, bc), -1.0, 1.0))
    return float(np.degrees(np.arccos(cos)))


def knee_flexion(hip: np.ndarray, knee: np.ndarray, ankle: np.ndarray) -> float:
    """Knee flexion in degrees: 0 = fully extended, increases as the knee bends."""
    interior = angle_at_joint(hip, knee, ankle)
    return float(max(0.0, 180.0 - interior))
