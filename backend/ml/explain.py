from __future__ import annotations

import numpy as np

from ml.features import FEATURE_NAMES, featurize_sequence


def explain_form(features: np.ndarray, baseline: np.ndarray | None = None) -> list[str]:
    baseline = baseline if baseline is not None else np.zeros_like(features)
    delta = features - baseline
    phrases: list[str] = []
    for name, d in zip(FEATURE_NAMES, delta):
        if abs(d) < 0.05:
            continue
        if name == "hip_rise_early" and d > 0:
            phrases.append("early hip rise")
        elif name == "bar_path_dev" and d > 0:
            phrases.append("bar path drift")
        elif name == "speed_drop" and d > 0:
            phrases.append("late-set velocity loss")
        else:
            phrases.append(f"{name} {'up' if d > 0 else 'down'}")
    return phrases or ["balanced mechanics"]
