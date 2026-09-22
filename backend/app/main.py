from __future__ import annotations

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.catalog import FoodCatalog, get_catalog
from app.config import get_settings
from app.errors import AppError, app_error_handler, validation_error_handler
from app.middleware.body_limit import RequestBodyLimitMiddleware
from app.models import HealthResponse
from app.providers import build_provider
from app.routes.analysis import router as analysis_router
from app.routes.billing import router as billing_router
from app.services.analysis import AnalysisService
from app.services.billing import GooglePlayVerifier
from app.startup import validate_production_configuration


def create_app() -> FastAPI:
    settings = get_settings()
    catalog = (
        get_catalog()
        if settings.nutrition_catalog_path is None
        else FoodCatalog.from_path(settings.nutrition_catalog_path)
    )
    validate_production_configuration(settings, catalog)
    provider = build_provider(settings, catalog)
    app = FastAPI(
        title=settings.app_name,
        version=__version__,
        docs_url="/docs" if settings.debug else None,
        redoc_url=None,
        openapi_url="/openapi.json" if settings.debug else None,
    )
    app.add_exception_handler(AppError, app_error_handler)  # type: ignore[arg-type]
    app.add_exception_handler(RequestValidationError, validation_error_handler)  # type: ignore[arg-type]
    app.add_middleware(
        CORSMiddleware,
        allow_origins=list(settings.cors_origins),
        allow_credentials=False,
        allow_methods=["GET", "POST", "OPTIONS"],
        allow_headers=["Authorization", "Content-Type"],
    )
    app.add_middleware(RequestBodyLimitMiddleware, max_bytes=settings.max_request_body_bytes)
    app.state.analysis_service = AnalysisService(provider=provider, catalog=catalog)
    app.state.billing_verifier = GooglePlayVerifier(settings)

    @app.get("/health", response_model=HealthResponse, tags=["system"])
    async def health() -> HealthResponse:
        return HealthResponse(status="ok", version=__version__, provider=provider.name)

    app.include_router(analysis_router, prefix=settings.api_prefix)
    app.include_router(billing_router, prefix=settings.api_prefix)
    return app


app = create_app()
