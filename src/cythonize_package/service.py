"""Business logic service - This file will be cythonized to protect business logic."""

from typing import Optional

from .models import User, UserResponse


class UserService:
    """Service for managing users - This logic will be protected by Cython."""

    def __init__(self):
        self._users: dict[int, UserResponse] = {}
        self._next_id: int = 1

    def create_user(self, user: User) -> UserResponse:
        """
        Create a new user.

        This method contains business logic that will be compiled to binary
        and protected from reverse engineering.
        """
        user_id = self._next_id
        self._next_id += 1

        user_response = UserResponse(
            id=user_id, name=user.name, email=user.email, age=user.age
        )

        self._users[user_id] = user_response
        return user_response

    def get_user(self, user_id: int) -> Optional[UserResponse]:
        """Get user by ID."""
        return self._users.get(user_id)

    def list_users(self) -> list[UserResponse]:
        """List all users."""
        return list(self._users.values())
