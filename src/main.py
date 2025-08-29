from fastapi import FastAPI

from src.api.routes.service_routers import service_router

app = FastAPI(title="fastapi-template")
app.include_router(service_router)
