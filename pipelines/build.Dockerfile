# syntax=docker/dockerfile:1

FROM python:3.10-slim

WORKDIR /app


RUN pip install --no-cache-dir --upgrade pip uv


COPY app/pyproject.toml* ./


RUN uv sync --all-extras


COPY ./app ./app
COPY ./tests ./tests
