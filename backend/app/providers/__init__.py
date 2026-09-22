from app.catalog import FoodCatalog
from app.config import Settings
from app.providers.base import RecognitionProvider
from app.providers.mock import MockRecognitionProvider
from app.providers.openai_compatible import OpenAICompatibleRecognitionProvider


def build_provider(settings: Settings, catalog: FoodCatalog) -> RecognitionProvider:
    if settings.provider == "mock":
        return MockRecognitionProvider()
    if settings.provider == "openai_compatible":
        return OpenAICompatibleRecognitionProvider(settings=settings, catalog=catalog)
    raise ValueError(f"Unsupported provider: {settings.provider}")


__all__ = ["RecognitionProvider", "build_provider"]
