"""FastAPI application - This file will be cythonized to protect source code."""

from fastapi import FastAPI

from .models import User, UserResponse
from .service import UserService


def create_app() -> FastAPI:
    """Create and configure FastAPI application."""
    app = FastAPI(
        title="Cythonized FastAPI Service",
        description="A FastAPI service with Cython-protected source code",
        version="0.1.0",
    )

    user_service = UserService()

    @app.get("/")
    async def root():
        """Root endpoint."""
        return {"message": "Welcome to Cythonized FastAPI Service"}

    @app.post("/users/", response_model=UserResponse)
    async def create_user(user: User):
        """Create a new user."""
        return user_service.create_user(user)

    @app.get("/users/{user_id}", response_model=UserResponse)
    async def get_user(user_id: int):
        """Get user by ID."""
        user = user_service.get_user(user_id)
        if user is None:
            from fastapi import HTTPException

            raise HTTPException(status_code=404, detail="User not found")
        return user

    @app.get("/users/", response_model=list[UserResponse])
    async def list_users():
        """List all users."""
        return user_service.list_users()

    return app


# Create app instance
app = create_app()


def get_app() -> FastAPI:
    """Get the FastAPI application instance."""
    return app
