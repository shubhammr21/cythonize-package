"""FastAPI application - THIS WILL BE COMPILED TO .so BY CYTHON.

Main app initialization with proprietary configuration.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from example_service.config import settings
from example_service.routes import router


def create_app() -> FastAPI:
    """Create FastAPI application with proprietary settings.

    This function contains confidential setup logic.

    Returns:
        Configured FastAPI application
    """
    app = FastAPI(
        title=settings.app_name,
        version="1.0.0",
        description="Example service with Cython protection",
        docs_url="/docs" if settings.debug else None,
        redoc_url="/redoc" if settings.debug else None,
    )

    # Proprietary CORS configuration
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"] if settings.debug else ["https://example.com"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Include routes
    app.include_router(router, prefix="/api/v1")

    # Add proprietary middleware
    @app.middleware("http")
    async def add_custom_headers(request, call_next):  # noqa: ANN202, ANN001
        """Add custom headers (proprietary logic)."""
        response = await call_next(request)
        # Secret headers
        response.headers["X-Service-Version"] = "1.0.0"
        rate_limit = settings.max_requests_per_minute
        response.headers["X-Rate-Limit"] = str(rate_limit)
        return response

    return app


app = create_app()
