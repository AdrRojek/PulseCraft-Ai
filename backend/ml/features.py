import numpy as np


FEATURE_NAMES = [
    "mean_knee_angle",
    "hip_rise_early",
    "bar_path_dev",
    "peak_velocity",
    "speed_drop",
]


def featurize_sequence(seq: np.ndarray) -> np.ndarray:
    # seq columns: t, hip_rise, knee_angle, bar_y, noise
    return np.array(
        [
            float(np.mean(seq[:, 2])),
            float(seq[5, 1]) if len(seq) > 5 else 0.0,
            float(np.std(seq[:, 3])),
            float(np.max(np.gradient(seq[:, 3], seq[:, 0]))),
            float(np.std(seq[:, 1])),
        ],
        dtype=np.float32,
    )
