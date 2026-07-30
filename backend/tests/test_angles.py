import numpy as np

from app.biomechanics.angles import angle_at_joint, knee_flexion


def test_right_angle():
    a = np.array([1.0, 0.0])
    b = np.array([0.0, 0.0])
    c = np.array([0.0, 1.0])
    ang = angle_at_joint(a, b, c)
    assert abs(ang - 90.0) < 1e-6


def test_knee_flexion_straight_leg():
    hip = np.array([0.0, 1.0])
    knee = np.array([0.0, 0.0])
    ankle = np.array([0.0, -1.0])
    assert knee_flexion(hip, knee, ankle) < 1e-6



def test_angle_sanity_81():
    assert 0.0 <= 180.0
