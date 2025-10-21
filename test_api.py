"""Test suite for the Cythonized FastAPI service."""

from fastapi.testclient import TestClient

from cythonize_package import get_app

client = TestClient(app=get_app())


def test_root() -> None:
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to Cythonized FastAPI Service"}


def test_create_user() -> int:
    """Test creating a new user."""
    user_data = {"name": "Test User", "email": "test@example.com", "age": 30}
    response = client.post("/users/", json=user_data)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Test User"
    assert data["email"] == "test@example.com"
    assert data["age"] == 30
    assert "id" in data
    return int(data["id"])


def test_get_user() -> None:
    """Test retrieving a specific user."""
    user_id = test_create_user()
    response = client.get(f"/users/{user_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == user_id


def test_list_users() -> None:
    """Test listing all users."""
    response = client.get("/users/")
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    assert len(users) > 0


if __name__ == "__main__":
    test_root()
    test_create_user()
    test_get_user()
    test_list_users()
