"""API routes - THIS WILL BE COMPILED TO .so BY CYTHON.

Route definitions and business logic hidden from users.
"""

from fastapi import APIRouter, HTTPException, status

from example_service.config import get_rate_limit, settings
from example_service.handlers import (
    ProcessedResponse,
    UserRequest,
    process_user_request,
)

router = APIRouter()


@router.get("/")
async def root() -> dict[str, str | int]:
    """Root endpoint.

    Returns:
        Welcome message
    """
    return {
        "service": settings.app_name,
        "version": "1.0.0",
        "status": "running",
        "rate_limit": get_rate_limit(),
    }


@router.get("/health")
async def health() -> dict[str, str]:
    """Health check endpoint.

    Returns:
        Health status
    """
    return {"status": "healthy", "timestamp": "2024-01-01T00:00:00Z"}


@router.post("/process")
async def process(request: UserRequest) -> ProcessedResponse:
    """Process user request with proprietary logic.

    Args:
        request: User request data

    Returns:
        Processed response
    """
    try:
        result = process_user_request(request)

        if result.status == "error":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail=result.message
            )

        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Processing failed: {e!s}",
        ) from e


@router.get("/config")
async def get_config() -> dict[str, str | bool | int]:
    """Get service configuration (protected info).

    Returns:
        Configuration data
    """
    # Only expose safe config
    return {
        "app_name": settings.app_name,
        "debug": settings.debug,
        "rate_limit": get_rate_limit(),
        # Secret values are hidden in compiled code
    }
