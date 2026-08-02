# Mobile TFLite integration

- Copy exported model to `mobile/assets/models/form_score.tflite`
- Load with `tflite_flutter` Interpreter in on-device scoring isolate
- Keep input vector aligned with `backend/ml/features.py` (5 floats)
