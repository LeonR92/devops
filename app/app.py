from flask import Flask, Response

app = Flask(__name__)

# Define a route for the homepage ("/")
@app.route('/')
def hello():
    """Returns a simple greeting."""
    return "Hello from Flask with Gunicorn!"


@app.route('/health')
def health_check():
    """A simple health check endpoint."""
    return Response("OK", status=200)
