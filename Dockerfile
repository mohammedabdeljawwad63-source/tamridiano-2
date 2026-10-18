FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    WORKERS=1 \
    LLM_BASE_URL=https://codecraftapi.com/v1 \
    LLM_MODEL=gemini-3.7-flash \
    LLM_MODEL_HEAVY=claude-opus-5 \
    EMAIL_PROVIDER=console \
    KEEP_ALIVE=true \
    KEEP_ALIVE_INTERVAL_MINUTES=10 \
    DB_POOL_SIZE=5 \
    DB_MAX_OVERFLOW=5

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential curl unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY *.zip /tmp/
RUN unzip -q /tmp/*.zip -d /app && rm -f /tmp/*.zip

RUN pip install --no-cache-dir -r requirements.txt \
    && chmod +x run.sh && mkdir -p data/uploads

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT:-8000}/api/health" || exit 1

CMD ["./run.sh"]
