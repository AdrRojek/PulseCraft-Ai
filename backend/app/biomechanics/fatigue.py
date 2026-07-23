import numpy as np


def concentric_speed_drop(rep_peak_velocities: list[float]) -> float:
    """Fatigue proxy: drop from first to last rep peak speed."""
    if len(rep_peak_velocities) < 2:
        return 0.0
    first, last = rep_peak_velocities[0], rep_peak_velocities[-1]
    if first <= 1e-9:
        return 0.0
    return float((first - last) / first)
