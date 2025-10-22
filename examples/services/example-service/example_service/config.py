"""Service configuration - THIS WILL BE COMPILED TO .so BY CYTHON.

Configuration and settings hidden from users.
"""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings with secret defaults."""

    app_name: str = "Example Service"
    debug: bool = False

    # Proprietary configuration
    secret_algorithm: str = "HS256"  # Hidden from users  # noqa: S105
    token_expiry: int = 3600
    max_requests_per_minute: int = 100

    # Internal API keys (example)
    internal_api_key: str = "secret-key-12345"

    class Config:
        """Pydantic config."""

        env_file = ".env"
        case_sensitive = False


# Singleton instance
settings = Settings()


def get_rate_limit() -> int:
    """Get proprietary rate limit calculation.

    This is business logic that should be hidden.

    Returns:
        Calculated rate limit
    """
    # Proprietary algorithm
    base_limit = settings.max_requests_per_minute
    if settings.debug:
        return base_limit * 10
    return base_limit


def calculate_timeout(request_size: int) -> float:
    """Calculate timeout based on proprietary formula.

    Args:
        request_size: Size of request in bytes

    Returns:
        Timeout in seconds
    """
    # Secret timeout calculation
    base_timeout = 5.0
    size_factor = request_size / 1024 / 1024  # MB

    # Proprietary scaling
    small_threshold = 1
    medium_threshold = 10
    if size_factor < small_threshold:
        return base_timeout
    if size_factor < medium_threshold:
        return base_timeout + size_factor * 0.5
    return (
        base_timeout + medium_threshold * 0.5 + (size_factor - medium_threshold) * 0.2
    )
