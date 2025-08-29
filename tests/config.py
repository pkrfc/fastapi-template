from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings


class SettingsForTests(BaseSettings):
    """Settings for integration tests (template)."""

    SERVICE_HOST: str = Field(default="service")
    SERVICE_PORT: int = Field(default=8000)

    BASE_URL: str = Field(default="")

    def model_post_init(self, __context, /) -> None:
        """Build base URL (http://host:port)."""
        self.BASE_URL = f"http://{self.SERVICE_HOST}:{self.SERVICE_PORT}"


@lru_cache
def get_test_settings():
    """Cached settings for tests."""
    return SettingsForTests()
