"""Firebase admin stub for cloud sync (no credentials in repo)."""


class FirebaseStub:
    def upload_session_summary(self, session_id: str, payload: dict) -> str:
        return f"stub://firebase/sessions/{session_id}"

    def fetch_plan(self, user_id: str) -> dict:
        return {"user_id": user_id, "plan": "starter_vbt"}


firebase_stub = FirebaseStub()
