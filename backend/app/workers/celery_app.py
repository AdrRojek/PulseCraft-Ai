from app.core.config import settings

try:
    from celery import Celery

    celery_app = Celery("pulsecraft", broker=settings.redis_url, backend=settings.redis_url)
    celery_app.conf.task_routes = {"app.workers.tasks.*": {"queue": "video"}}
except ImportError:  # pragma: no cover - optional in lightweight test envs
    class _StubTask:
        def delay(self, *args, **kwargs):
            return {"args": args, "kwargs": kwargs, "status": "stubbed"}

    class _StubCelery:
        def task(self, *args, **kwargs):
            def deco(fn):
                fn.delay = lambda *a, **k: fn(*a, **k)
                return fn

            return deco

    celery_app = _StubCelery()
