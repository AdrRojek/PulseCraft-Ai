import numpy as np


def clamp(value: float, lo: float, hi: float) -> float:
    return float(np.clip(value, lo, hi))


def unit_vector(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    v = b - a
    n = np.linalg.norm(v)
    if n < 1e-9:
        return np.zeros_like(v)
    return v / n


def moving_average(x: np.ndarray, window: int = 3) -> np.ndarray:
    if window <= 1:
        return x
    kernel = np.ones(window) / window
    return np.convolve(x, kernel, mode="same")
