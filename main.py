"""Entry point for running the FastAPI service."""

import uvicorn


def main() -> None:
    """Run the FastAPI service."""
    uvicorn.run(
        "cythonize_package:app",
        host="127.0.0.1",  # Bind to localhost only for security
        port=8000,
        reload=True,
    )


if __name__ == "__main__":
    main()
