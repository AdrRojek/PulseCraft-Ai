# Contributing

1. `python -m venv .venv && source .venv/bin/activate`
2. `pip install -r backend/requirements.txt`
3. `cd mobile && flutter pub get`
4. Train: `make train`
5. Export TFLite: `python -m ml.export_tflite`
