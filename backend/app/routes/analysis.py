from __future__ import annotations

from typing import Annotated, Literal, cast

from fastapi import APIRouter, File, Form, Request, UploadFile

from app.config import get_settings
from app.errors import AppError
from app.models import AnalyzeResponse, Locale
from app.providers.base import ProviderError
from app.services.analysis import AnalysisService
from app.services.images import validate_image


router = APIRouter(tags=["analysis"])


@router.post("/analyze", response_model=AnalyzeResponse)
async def analyze_food(
    request: Request,
    image: Annotated[UploadFile, File(description="JPEG, PNG, or WebP meal image")],
    locale: Annotated[Literal["en", "id"], Form()] = "en",
    source: Annotated[Literal["camera", "gallery"], Form()] = "camera",
) -> AnalyzeResponse:
    del source
    settings = get_settings()
    try:
        content = await image.read(settings.max_upload_bytes + 1)
    finally:
        await image.close()
    if len(content) > settings.max_upload_bytes:
        raise AppError(
            code="upload_too_large",
            message=f"Image exceeds the {settings.max_upload_bytes // (1024 * 1024)} MB upload limit.",
            status_code=413,
        )
    validated = validate_image(
        content=content,
        declared_content_type=image.content_type,
        max_pixels=settings.max_image_pixels,
    )
    service = cast(AnalysisService, request.app.state.analysis_service)
    try:
        return await service.analyze(
            image=validated.content,
            mime_type=validated.mime_type,
            filename=image.filename,
            locale=cast(Locale, locale),
        )
    except ProviderError as exc:
        raise AppError(
            code="recognition_provider_failed",
            message="The image recognition service could not analyze this photo.",
            status_code=502,
        ) from exc
