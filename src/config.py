import time
from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings


class ConstSettings(BaseSettings):
    """Application constant settings."""

    PROJECT_NAME: str = Field(default="fastapi-template", description="Service name")
    REDIS_RESULT_EX_TIME: int = Field(default=3600, description="TTL for task results in seconds")
    REDIS_XREAD_COUNT: int = Field(default=100, description="Batch size for Redis Streams reads")


class DevSettings(BaseSettings):
    """Environment-driven settings."""

    DATABASE_URL: str = Field(
        default="postgresql+asyncpg://postgres:postgres@localhost:5432/app_db", description="Database URL"
    )
    REDIS_URL: str = Field(default="redis://localhost:6379/0", description="Redis DSN for task broker")


class RuntimeContext:
    """Created once at FastAPI startup."""

    start_time: float | None = Field(default=None, description="Application start time")

    def __init__(self) -> None:
        """Initialize runtime context."""
        self.start_time = time.time()


runtime_context = RuntimeContext()
_const_settings: ConstSettings | None = None
_dev_settings: DevSettings | None = None


@lru_cache
def get_const_settings() -> ConstSettings:
    """Return constant settings (cached)."""
    global _const_settings
    if not _const_settings:
        _const_settings = ConstSettings()
    return _const_settings


@lru_cache
def get_settings() -> DevSettings:
    """Return environment settings (cached)."""
    global _dev_settings
    if not _dev_settings:
        _dev_settings = DevSettings()
    return _dev_settings
