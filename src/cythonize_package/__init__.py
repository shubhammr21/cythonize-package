"""Cythonize Package - A FastAPI service with protected source code."""

__version__ = "0.1.0"

from .app import app, get_app

__all__ = ["__version__", "app", "get_app"]
