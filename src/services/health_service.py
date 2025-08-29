import time
from functools import lru_cache

from src.api.schemas.health import HealthResponse
from src.config import get_const_settings, runtime_context


class HealthService:
    """Health check service."""

    def __init__(self) -> None:
        """Initialize service."""
        self._runtime_context = runtime_context

    async def get_health_status(self) -> HealthResponse:
        """Return service health status."""
        uptime_min: float | None = None
        if self._runtime_context.start_time:
            uptime_min = round((time.time() - self._runtime_context.start_time) / 60.0, 2)

        service_name = get_const_settings().PROJECT_NAME
        return HealthResponse(service=service_name, uptime=uptime_min)


@lru_cache
def get_health_service() -> HealthService:
    """Cached provider for HealthService."""
    return HealthService()
