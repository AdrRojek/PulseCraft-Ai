# PulseCraft AI

Intelligent strength-training & biomechanics assistant.

## Live path (on-device)
Phone camera → MediaPipe pose → joint angles / VBT features → **TFLite FormScore** → Flutter HUD (score ring, sticking pulse, haptics).

## Backend
FastAPI + WebSocket keypoint sync, Celery/Redis async video jobs, SHAP explanations after a set, Firebase stubs for auth/storage.

## Model
`FormScoreRegressor` (PyTorch MLP) trained on synthetic + processed pose features, exported to `artifacts/form_score.tflite` for mobile.

## Monorepo
- `mobile/` Flutter + BLoC (Precision Gym Lab UI)
- `backend/` FastAPI + CV/biomechanics + ML
- `shared/` design tokens & exercise profiles
- `artifacts/` model weights

## Disclaimer
Coaching assistant — not a medical device. No clinical claims.
