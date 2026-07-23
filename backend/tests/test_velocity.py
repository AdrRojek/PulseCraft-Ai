import numpy as np

from app.biomechanics.velocity import velocity_1d, peak_concentric_velocity


def test_constant_velocity():
    t = np.linspace(0, 1, 11)
    pos = 2.0 * t
    v = velocity_1d(pos, dt=0.1)
    assert np.allclose(v, 2.0, atol=1e-6)
    assert abs(peak_concentric_velocity(pos, 0.1) - 2.0) < 1e-6
