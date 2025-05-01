# MyFunction/__init__.py
from azure.functions import WsgiMiddleware

from app.main import app

main = WsgiMiddleware(app).main
