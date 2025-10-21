"""Main entry point for running the FastAPI service."""

import uvicorn


def main():
    """Run the FastAPI service."""
    uvicorn.run(
        "cythonize_package:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )


if __name__ == "__main__":
    main()
