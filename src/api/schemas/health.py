from pydantic import BaseModel, Field

from src.config import get_const_settings


class HealthResponse(BaseModel):
    """Response model for service health check."""

    service: str = Field(default=get_const_settings().PROJECT_NAME, description="Service name")
    uptime: float | None = Field(default=None, description="Service uptime in minutes")
