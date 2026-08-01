from __future__ import annotations

import json
from pathlib import Path

import torch
from torch.utils.data import DataLoader, TensorDataset

from ml.features import featurize_sequence
from ml.models.form_score import FormScoreRegressor
from ml.synthetic import generate_squat_sequence


def build_dataset(n: int = 256) -> TensorDataset:
    xs, ys = [], []
    for i in range(n):
        seq = generate_squat_sequence(seed=i)
        xs.append(featurize_sequence(seq))
        ys.append(float(0.55 + 0.35 * (i % 7) / 6))
    x = torch.tensor(xs, dtype=torch.float32)
    y = torch.tensor(ys, dtype=torch.float32)
    return TensorDataset(x, y)


def train(out_dir: Path = Path("artifacts")) -> dict[str, float]:
    out_dir.mkdir(parents=True, exist_ok=True)
    ds = build_dataset()
    loader = DataLoader(ds, batch_size=32, shuffle=True)
    model = FormScoreRegressor(in_features=5)
    opt = torch.optim.Adam(model.parameters(), lr=1e-3)
    loss_fn = torch.nn.MSELoss()
    for _ in range(5):
        for xb, yb in loader:
            opt.zero_grad()
            pred = model(xb)
            loss = loss_fn(pred, yb)
            loss.backward()
            opt.step()
    path = out_dir / "form_score_model.pt"
    torch.save(model.state_dict(), path)
    metrics = {"train_mse": float(loss.detach())}
    (out_dir / "metrics.json").write_text(json.dumps(metrics, indent=2), encoding="utf-8")
    return metrics


if __name__ == "__main__":
    train()
