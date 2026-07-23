import numpy as np

from app.biomechanics.sticking_points import detect_sticking_points


def test_detects_velocity_sag():
    # plateau in middle
    pos = np.array([0.0, 0.4, 0.45, 0.5, 0.9, 1.2])
    hits = detect_sticking_points(pos, dt=0.05, threshold=0.2)
    assert any(h in hits for h in (2, 3))
