# syntax=docker/dockerfile:1

FROM python:3.10-slim as builder
WORKDIR /app
RUN pip install --no-cache-dir --upgrade pip uv
COPY app/pyproject.toml* ./
RUN uv sync --system --all-extras
COPY app/ ./app/

FROM python:3.10-slim
WORKDIR /app
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --ingroup appgroup appuser
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app
USER appuser
CMD ["python", "--version"]
