"""Example package with Cython protection.

This file is NOT compiled - it serves as an entry point.
"""

from example_package.utils import calculate_score, format_message
from example_package.validators import validate_age, validate_email

__version__ = "1.0.0"
__all__ = [
    "calculate_score",
    "format_message",
    "validate_age",
    "validate_email",
]
