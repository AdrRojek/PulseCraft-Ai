import numpy as np
from ml.synthetic import generate_squat_sequence
from ml.features import featurize_sequence


def test_feat_len_65():
    seq = generate_squat_sequence(seed=65)
    v = featurize_sequence(seq)
    assert v.shape == (5,)
