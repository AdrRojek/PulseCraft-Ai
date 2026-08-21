import torch
from torch import nn


class FormScoreRegressor(nn.Module):
    """MLP: joint/VBT features -> form score + error probabilities."""

    def __init__(self, in_features: int = 5, hidden: int = 64, n_errors: int = 3, in_dim: int | None = None):
        super().__init__()
        if in_dim is not None:
            in_features = in_dim
        self.in_features = in_features
        self.backbone = nn.Sequential(
            nn.Linear(in_features, hidden),
            nn.ReLU(),
            nn.Linear(hidden, hidden),
            nn.ReLU(),
        )
        self.score_head = nn.Sequential(nn.Linear(hidden, 1), nn.Sigmoid())
        self.error_head = nn.Sequential(nn.Linear(hidden, n_errors), nn.Sigmoid())
        self.error_names = ["early_hip_rise", "forward_lean", "velocity_fade"]

    def forward(self, x: torch.Tensor):
        h = self.backbone(x)
        return self.score_head(h).squeeze(-1), self.error_head(h)
