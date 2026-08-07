import numpy as np
from ml.synthetic import generate_squat_sequence
from ml.features import featurize_sequence


def test_feat_len_55():
    seq = generate_squat_sequence(seed=55)
    v = featurize_sequence(seq)
    assert v.shape == (5,)
