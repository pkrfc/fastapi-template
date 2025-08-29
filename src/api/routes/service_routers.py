from fastapi import APIRouter, Depends

from src.api.schemas.health import HealthResponse
from src.services.health_service import HealthService, get_health_service

service_router = APIRouter(prefix="", tags=["Service Info"])


@service_router.get("/health", response_model=HealthResponse)
async def health_check(service: HealthService = Depends(get_health_service)) -> HealthResponse:
    """Service health check endpoint."""
    return await service.get_health_status()
