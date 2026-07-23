import numpy as np


def velocity_1d(positions: np.ndarray, dt: float) -> np.ndarray:
    """Concentric VBT: v = dx/dt along primary axis."""
    if dt <= 0:
        raise ValueError("dt must be positive")
    return np.gradient(positions, dt)


def peak_concentric_velocity(positions: np.ndarray, dt: float) -> float:
    v = velocity_1d(positions, dt)
    return float(np.max(v))


def mean_concentric_velocity(positions: np.ndarray, dt: float) -> float:
    v = velocity_1d(positions, dt)
    return float(np.mean(v[v > 0])) if np.any(v > 0) else 0.0
