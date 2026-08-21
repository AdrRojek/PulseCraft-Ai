"""Train FormScoreRegressor and export .pt + real .tflite (+ mobile asset copy)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
import torch
from torch import nn
from torch.utils.data import DataLoader, TensorDataset

OUT = Path(__file__).resolve().parents[2] / "artifacts"


class FormScoreRegressor(nn.Module):
    def __init__(self, in_features: int = 5, hidden: int = 64, n_errors: int = 3):
        super().__init__()
        self.backbone = nn.Sequential(
            nn.Linear(in_features, hidden),
            nn.ReLU(),
            nn.Linear(hidden, hidden),
            nn.ReLU(),
        )
        self.score_head = nn.Sequential(nn.Linear(hidden, 1), nn.Sigmoid())
        self.error_head = nn.Sequential(nn.Linear(hidden, n_errors), nn.Sigmoid())

    def forward(self, x: torch.Tensor):
        h = self.backbone(x)
        return self.score_head(h).squeeze(-1), self.error_head(h)


def make_data(n: int = 512, seed: int = 0):
    rng = np.random.default_rng(seed)
    xs, scores, errs = [], [], []
    for i in range(n):
        # features: mean_knee, hip_rise_early, bar_path_dev, peak_vel, speed_drop
        hip = float(rng.uniform(0, 0.35))
        lean = float(rng.uniform(0, 0.4))
        speed_drop = float(rng.uniform(0, 0.5))
        x = np.array(
            [
                float(rng.normal(105, 10)),
                hip,
                lean,
                float(rng.uniform(0.3, 0.9)),
                speed_drop,
            ],
            dtype=np.float32,
        )
        # Heuristic labels
        score = 1.0 - 0.9 * hip - 0.7 * lean - 0.5 * speed_drop
        score = float(np.clip(score + rng.normal(0, 0.03), 0.05, 0.98))
        e = np.array(
            [
                1 / (1 + np.exp(-12 * (hip - 0.12))),
                1 / (1 + np.exp(-12 * (lean - 0.15))),
                1 / (1 + np.exp(-10 * (speed_drop - 0.2))),
            ],
            dtype=np.float32,
        )
        xs.append(x)
        scores.append(score)
        errs.append(e)
    return (
        torch.tensor(np.stack(xs)),
        torch.tensor(scores, dtype=torch.float32),
        torch.tensor(np.stack(errs)),
    )


def train_torch() -> dict:
    OUT.mkdir(parents=True, exist_ok=True)
    x, y, e = make_data()
    # holdout
    n = len(x)
    n_val = n // 5
    x_tr, y_tr, e_tr = x[n_val:], y[n_val:], e[n_val:]
    x_va, y_va, e_va = x[:n_val], y[:n_val], e[:n_val]
    ds = TensorDataset(x_tr, y_tr, e_tr)
    loader = DataLoader(ds, batch_size=32, shuffle=True)
    model = FormScoreRegressor()
    opt = torch.optim.Adam(model.parameters(), lr=1e-3)
    mse = nn.MSELoss()
    bce = nn.BCELoss()
    for epoch in range(40):
        model.train()
        for xb, yb, eb in loader:
            opt.zero_grad()
            ps, pe = model(xb)
            loss = mse(ps, yb) + 0.5 * bce(pe, eb)
            loss.backward()
            opt.step()
    model.eval()
    with torch.no_grad():
        ps, pe = model(x_va)
        mae = float(torch.mean(torch.abs(ps - y_va)))
        mse_v = float(torch.mean((ps - y_va) ** 2))
    pt_path = OUT / "form_score_model.pt"
    torch.save(
        {
            "state_dict": model.state_dict(),
            "in_features": 5,
            "hidden": 64,
            "n_errors": 3,
            "error_names": ["early_hip_rise", "forward_lean", "velocity_fade"],
        },
        pt_path,
    )
    # Also save raw state_dict compatible with simpler loader
    torch.save(model.state_dict(), OUT / "form_score_state.pt")
    metrics = {"val_mae": mae, "val_mse": mse_v, "epochs": 40, "n_train": int(n - n_val)}
    (OUT / "metrics.json").write_text(json.dumps(metrics, indent=2))
    return metrics, model


def export_tflite_from_keras(torch_model: FormScoreRegressor) -> Path:
    import tensorflow as tf

    # Build TF twin and copy weights approx by matching layer order
    inp = tf.keras.Input(shape=(5,), name="features")
    h = tf.keras.layers.Dense(64, activation="relu", name="fc1")(inp)
    h = tf.keras.layers.Dense(64, activation="relu", name="fc2")(h)
    score = tf.keras.layers.Dense(1, activation="sigmoid", name="score")(h)
    errors = tf.keras.layers.Dense(3, activation="sigmoid", name="errors")(h)
    km = tf.keras.Model(inp, [score, errors])

    # Copy weights from torch
    sd = torch_model.state_dict()
    km.get_layer("fc1").set_weights(
        [sd["backbone.0.weight"].T.numpy(), sd["backbone.0.bias"].numpy()]
    )
    km.get_layer("fc2").set_weights(
        [sd["backbone.2.weight"].T.numpy(), sd["backbone.2.bias"].numpy()]
    )
    km.get_layer("score").set_weights(
        [sd["score_head.0.weight"].T.numpy(), sd["score_head.0.bias"].numpy()]
    )
    km.get_layer("errors").set_weights(
        [sd["error_head.0.weight"].T.numpy(), sd["error_head.0.bias"].numpy()]
    )

    converter = tf.lite.TFLiteConverter.from_keras_model(km)
    tflite_model = converter.convert()
    out = OUT / "form_score.tflite"
    out.write_bytes(tflite_model)
    return out


def main():
    metrics, model = train_torch()
    print("torch metrics", metrics)
    try:
        path = export_tflite_from_keras(model)
        print("tflite", path, "bytes", path.stat().st_size)
    except Exception as exc:
        print("tflite export failed:", exc, file=sys.stderr)
        # write a minimal fallback note — generator will prefer real file
        raise
    print("done", OUT)


if __name__ == "__main__":
    main()
