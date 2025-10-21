"""Pydantic models - This file will be cythonized."""

from pydantic import BaseModel, EmailStr, Field


class User(BaseModel):
    """User model for creation."""

    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    age: int = Field(..., ge=0, le=150)


class UserResponse(BaseModel):
    """User response model."""

    id: int
    name: str
    email: str
    age: int

    class Config:
        from_attributes = True
