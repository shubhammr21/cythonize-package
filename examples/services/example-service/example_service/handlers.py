"""Request handlers - THIS WILL BE COMPILED TO .so BY CYTHON.

Business logic for request handling hidden from users.
"""

from datetime import datetime

from example_package import calculate_score, format_message, validate_email
from pydantic import BaseModel


class UserRequest(BaseModel):
    """User request model."""

    name: str
    email: str
    age: int


class ProcessedResponse(BaseModel):
    """Processed response model."""

    status: str
    message: str
    timestamp: str
    score: float


def process_user_request(request: UserRequest) -> ProcessedResponse:
    """Process user request with proprietary logic.

    This contains confidential business logic.

    Args:
        request: User request data

    Returns:
        Processed response
    """
    # Validate email using shared package
    validation = validate_email(request.email)
    if not validation["valid"]:
        return ProcessedResponse(
            status="error",
            message=validation["message"],
            timestamp=datetime.now().isoformat(),
            score=0.0,
        )

    # Proprietary processing logic
    user_data = {
        "accuracy": calculate_user_accuracy(request.name),
        "speed": calculate_response_speed(request.age),
        "quality": calculate_quality_score(request.email),
    }

    # Calculate proprietary score
    score = calculate_score(user_data)

    # Format response message (using shared package)
    message = format_message(
        request.name, f"Request processed successfully. Score: {score:.2f}"
    )

    return ProcessedResponse(
        status="success",
        message=message,
        timestamp=datetime.now().isoformat(),
        score=score,
    )


def calculate_user_accuracy(name: str) -> float:
    """Calculate user accuracy score (proprietary algorithm).

    Args:
        name: User name

    Returns:
        Accuracy score
    """
    # Secret scoring algorithm
    base_score = 50.0
    length_factor = len(name) * 2.5
    return min(base_score + length_factor, 100.0)


def calculate_response_speed(age: int) -> float:
    """Calculate response speed score (proprietary).

    Args:
        age: User age

    Returns:
        Speed score
    """
    # Proprietary age-based calculation
    young_age = 25
    mid_age = 40
    senior_age = 60
    if age < young_age:
        return 90.0
    if age < mid_age:
        return 75.0
    if age < senior_age:
        return 60.0
    return 50.0


def calculate_quality_score(email: str) -> float:
    """Calculate quality score (confidential).

    Args:
        email: User email

    Returns:
        Quality score
    """
    # Secret quality algorithm
    domain = email.split("@")[1]
    premium_domains = ["gmail.com", "outlook.com", "company.com"]

    if domain in premium_domains:
        return 85.0
    return 60.0
