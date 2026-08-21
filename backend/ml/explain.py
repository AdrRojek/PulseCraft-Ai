from __future__ import annotations

import numpy as np

ERROR_LABELS = {
    "early_hip_rise": "too-early hip rise",
    "forward_lean": "excessive torso lean",
    "velocity_fade": "concentric velocity fade (VBT fatigue)",
}


def explain_prediction(score_0_100: float, error_probs: dict[str, float]) -> str:
    ranked = sorted(error_probs.items(), key=lambda kv: kv[1], reverse=True)
    top_name, top_p = ranked[0]
    if top_p < 0.25:
        return f"Movement scored {score_0_100:.0f}% with balanced joint timing."
    label = ERROR_LABELS.get(top_name, top_name)
    return (
        f"Movement scored {score_0_100:.0f}% largely due to {label} "
        f"(contribution ~{top_p*100:.0f}%)."
    )


def example_explanation() -> str:
    return explain_prediction(
        72.0,
        {"early_hip_rise": 0.61, "forward_lean": 0.22, "velocity_fade": 0.18},
    )
