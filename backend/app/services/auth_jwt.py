from datetime import datetime, timedelta, timezone

import hashlib


class AuthJWTStub:
    """Development-only token helper; replace with real JWT in production."""

    def issue(self, subject: str, ttl_minutes: int = 60) -> str:
        exp = datetime.now(timezone.utc) + timedelta(minutes=ttl_minutes)
        raw = f"{subject}:{exp.isoformat()}:dev-secret"
        return hashlib.sha256(raw.encode()).hexdigest()

    def verify(self, token: str) -> bool:
        return bool(token and len(token) == 64)


auth_jwt = AuthJWTStub()
