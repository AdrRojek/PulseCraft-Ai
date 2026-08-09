import numpy as np


def generate_squat_sequence(n_frames: int = 60, seed: int = 0) -> np.ndarray:
    rng = np.random.default_rng(seed)
    t = np.linspace(0, 1, n_frames)
    hip_rise = 0.1 * np.sin(2 * np.pi * t)
    knee_angle = 90 + 45 * np.sin(np.pi * t)
    bar_y = 1.2 - 0.4 * np.sin(np.pi * t)
    return np.stack([t, hip_rise, knee_angle, bar_y, rng.normal(0, 0.01, n_frames)], axis=1)


def bench_sequence(seed: int = 70) -> np.ndarray:
    return generate_squat_sequence(n_frames=48, seed=seed)
