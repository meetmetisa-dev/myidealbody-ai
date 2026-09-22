from __future__ import annotations

import io
import warnings
from dataclasses import dataclass

from PIL import Image, UnidentifiedImageError

from app.errors import AppError


ALLOWED_CONTENT_TYPES = frozenset({"image/jpeg", "image/png", "image/webp"})
FORMAT_CONTENT_TYPES = {"JPEG": "image/jpeg", "PNG": "image/png", "WEBP": "image/webp"}


@dataclass(frozen=True, slots=True)
class ValidatedImage:
    content: bytes
    mime_type: str
    width: int
    height: int


def validate_image(
    *,
    content: bytes,
    declared_content_type: str | None,
    max_pixels: int,
) -> ValidatedImage:
    declared = (declared_content_type or "").split(";", 1)[0].strip().lower()
    if declared not in ALLOWED_CONTENT_TYPES:
        raise AppError(
            code="unsupported_image_type",
            message="Use a JPEG, PNG, or WebP image.",
            status_code=415,
        )
    if not content:
        raise AppError(code="empty_image", message="The uploaded image is empty.", status_code=400)

    try:
        with warnings.catch_warnings():
            warnings.simplefilter("error", Image.DecompressionBombWarning)
            with Image.open(io.BytesIO(content)) as image:
                detected = FORMAT_CONTENT_TYPES.get(image.format or "")
                width, height = image.size
                if width * height > max_pixels:
                    raise AppError(
                        code="image_too_large",
                        message="The decoded image dimensions are too large.",
                        status_code=413,
                    )
                image.verify()
    except (UnidentifiedImageError, OSError, SyntaxError, Image.DecompressionBombWarning, Image.DecompressionBombError) as exc:
        raise AppError(
            code="invalid_image",
            message="The file is not a valid or safely decodable image.",
            status_code=400,
        ) from exc
    if detected not in ALLOWED_CONTENT_TYPES:
        raise AppError(
            code="unsupported_image_type",
            message="Use a JPEG, PNG, or WebP image.",
            status_code=415,
        )
    if detected != declared:
        raise AppError(
            code="image_type_mismatch",
            message="The declared image type does not match the file.",
            status_code=400,
        )
    if width < 64 or height < 64:
        raise AppError(
            code="image_too_small",
            message="The image must be at least 64 by 64 pixels.",
            status_code=400,
        )
    return ValidatedImage(content=content, mime_type=detected, width=width, height=height)
