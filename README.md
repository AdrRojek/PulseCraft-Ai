# PulseCraft AI

Intelligent strength-training & biomechanics assistant.

## Live path (on-device)
Phone camera → MediaPipe pose → joint angles / VBT features → **TFLite FormScore** → Flutter HUD.

## Backend
FastAPI + WebSocket keypoint sync, Celery/Redis async video jobs, SHAP-style explanations, Firebase stubs.

## Model
`FormScoreRegressor` (PyTorch MLP, multi-head) trained on synthetic biomechanical features, exported to `artifacts/form_score.tflite`.

See `artifacts/metrics.json` for holdout MAE.

## Monorepo
- `mobile/` Flutter + BLoC (Precision Gym Lab UI)
- `backend/` FastAPI + CV/biomechanics + ML
- `shared/` design tokens & exercise profiles
- `artifacts/` model weights

## Disclaimer
Coaching assistant — not a medical device. No clinical claims.
