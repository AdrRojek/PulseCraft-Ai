from pathlib import Path

import numpy as np
import torch

from ml.features import featurize_sequence
from ml.models.form_score import FormScoreRegressor
from ml.synthetic import generate_squat_sequence


def load_model(path: Path) -> FormScoreRegressor:
    model = FormScoreRegressor(in_features=5)
    model.load_state_dict(torch.load(path, map_location="cpu"))
    model.eval()
    return model


def score_sequence(model: FormScoreRegressor, seq: np.ndarray) -> float:
    x = torch.tensor(featurize_sequence(seq)).unsqueeze(0)
    with torch.no_grad():
        return float(model(x).item())


if __name__ == "__main__":
    m = load_model(Path("artifacts/form_score_model.pt"))
    seq = generate_squat_sequence()
    print(score_sequence(m, seq))
