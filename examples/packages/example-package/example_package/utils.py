"""Utility functions - THIS WILL BE COMPILED TO .so BY CYTHON.

Business logic is hidden in this file.
"""

import hashlib
from datetime import datetime


def format_message(name: str, message: str) -> str:
    """Format a message with timestamp and name.

    This is business logic that will be hidden from users.

    Args:
        name: User name
        message: Message content

    Returns:
        Formatted message string
    """
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"[{timestamp}] {name}: {message}"


def calculate_score(data: dict[str, float]) -> float:
    """Calculate a proprietary score from data.

    This represents confidential business logic.

    Args:
        data: Dictionary of metrics

    Returns:
        Calculated score
    """
    # This is proprietary algorithm logic
    base_score = sum(data.values()) / len(data)

    # Apply secret weighting algorithm
    weights = {
        "accuracy": 2.0,
        "speed": 1.5,
        "quality": 3.0,
    }

    weighted_score = sum(data.get(key, 0) * weight for key, weight in weights.items())

    return (base_score + weighted_score) / 2


def generate_api_key(user_id: str, secret: str) -> str:
    """Generate API key - sensitive logic.

    Args:
        user_id: User identifier
        secret: Secret key

    Returns:
        Generated API key
    """
    combined = f"{user_id}:{secret}:{datetime.now().isoformat()}"
    return hashlib.sha256(combined.encode()).hexdigest()
