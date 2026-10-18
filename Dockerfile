# Tamridiano — production image.
# Multi-worker uvicorn behind the platform's proxy; no build step for the
# front-end (plain HTML/CSS/JS served by FastAPI).
FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8000 \
    WORKERS=4

WORKDIR /app

# Build tools are needed by some wheels (cryptography) on slim images.
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && pip install --no-cache-dir "asyncpg>=0.29"

COPY app ./app
COPY run.sh ./run.sh
RUN chmod +x run.sh && mkdir -p data/uploads

# Run as a non-root user; the data volume must stay writable by it.
RUN useradd --create-home --uid 10001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT}/api/health" || exit 1

CMD ["./run.sh"]
