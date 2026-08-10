import numpy as np
from ml.synthetic import generate_squat_sequence
from ml.features import featurize_sequence


def test_feat_len_85():
    seq = generate_squat_sequence(seed=85)
    v = featurize_sequence(seq)
    assert v.shape == (5,)
