"""Example FastAPI service with Cython protection.

This file is NOT compiled - it serves as an entry point.
"""

from example_service.main import app

__version__ = "1.0.0"
__all__ = ["app"]
