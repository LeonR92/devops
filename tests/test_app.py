# test_app.py
import pytest

from app.app import app  # Import your Flask app object


@pytest.fixture()
def client():
    """Create a test client for the Flask app."""
    # Configure the app for testing
    app.config.update({
        "TESTING": True,
    })
    # Yield the test client
    with app.test_client() as client:
        yield client
    # Cleanup can go here if needed after 'yield'

# --- Test Functions ---

def test_hello_route(client):
    """Test the '/' route."""
    response = client.get('/')
    assert response.status_code == 200
    assert response.data == b"Hello from Flask with Gunicorn!" # Response data is in bytes

def test_health_check_route(client):
    """Test the '/health' route."""
    response = client.get('/health')
    assert response.status_code == 200
    assert response.data == b"OK" # Response data is in bytes

def test_nonexistent_route(client):
    """Test accessing a route that doesn't exist."""
    response = client.get('/nonexistent-page')
    # Flask typically returns a 404 Not Found for routes that aren't defined
    assert response.status_code == 404