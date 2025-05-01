# MyFunction/__init__.py
from azure.functions import WsgiMiddleware

from app.app import app

main = WsgiMiddleware(app).main
