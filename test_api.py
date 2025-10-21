"""Test script for the cythonized FastAPI service."""

from fastapi.testclient import TestClient

from cythonize_package import app

client = TestClient(app)


def test_root():
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to Cythonized FastAPI Service"}
    print("✅ Root endpoint test passed")


def test_create_user():
    """Test creating a user."""
    user_data = {"name": "John Doe", "email": "john@example.com", "age": 30}
    response = client.post("/users/", json=user_data)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "John Doe"
    assert data["email"] == "john@example.com"
    assert data["age"] == 30
    assert "id" in data
    print(f"✅ Create user test passed: {data}")
    return data["id"]


def test_get_user():
    """Test getting a user by ID."""
    # First create a user
    user_id = test_create_user()

    # Now get the user
    response = client.get(f"/users/{user_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == user_id
    print(f"✅ Get user test passed: {data}")


def test_list_users():
    """Test listing all users."""
    response = client.get("/users/")
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    print(f"✅ List users test passed: {len(users)} users found")


if __name__ == "__main__":
    print("Testing Cythonized FastAPI Service...\n")
    test_root()
    test_create_user()
    test_get_user()
    test_list_users()
    print("\n🎉 All tests passed!")
    print("\n🎉 All tests passed!")
