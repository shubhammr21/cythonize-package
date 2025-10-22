"""Validation logic - THIS WILL BE COMPILED TO .so BY CYTHON.

Business validation rules hidden from users.
"""

import re
from typing import TypedDict


class ValidationResult(TypedDict):
    """Validation result."""

    valid: bool
    message: str


def validate_email(email: str) -> ValidationResult:
    """Validate email with proprietary rules.

    Args:
        email: Email address to validate

    Returns:
        Validation result
    """
    # Basic format check
    pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    if not re.match(pattern, email):
        return {"valid": False, "message": "Invalid email format"}

    # Proprietary domain validation
    blocked_domains = ["tempmail.com", "throwaway.email"]
    domain = email.split("@")[1]
    if domain in blocked_domains:
        return {"valid": False, "message": "Domain not allowed"}

    return {"valid": True, "message": "Valid email"}


def validate_age(age: int) -> ValidationResult:
    """Validate age with business rules.

    Args:
        age: Age to validate

    Returns:
        Validation result
    """
    # Proprietary age validation logic
    min_age = 18
    max_age = 120

    if age < min_age:
        return {"valid": False, "message": f"Minimum age is {min_age}"}

    if age > max_age:
        return {"valid": False, "message": f"Maximum age is {max_age}"}

    # Additional proprietary checks
    restricted_ages = [21, 25, 30]  # Business logic
    category = "standard"
    for threshold in restricted_ages:
        if age >= threshold:
            category = f"tier-{threshold}"

    return {
        "valid": True,
        "message": f"Valid age, category: {category}",
    }


def validate_password(password: str) -> ValidationResult:
    """Validate password with secret rules.

    Args:
        password: Password to validate

    Returns:
        Validation result
    """
    # Proprietary password strength algorithm
    min_password_length = 12
    if len(password) < min_password_length:
        return {"valid": False, "message": "Password too short"}

    # Secret scoring system
    score = 0
    if re.search(r"[A-Z]", password):
        score += 2
    if re.search(r"[a-z]", password):
        score += 2
    if re.search(r"\d", password):
        score += 3
    if re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        score += 4

    # Proprietary threshold
    required_score = 8
    if score < required_score:
        return {"valid": False, "message": "Password not strong enough"}

    return {"valid": True, "message": "Strong password"}
