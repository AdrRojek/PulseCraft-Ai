.PHONY: api test-backend train

api:
	cd backend && uvicorn app.main:app --reload --port 8000

test-backend:
	cd backend && pytest -q

train:
	cd backend && python -m ml.train
