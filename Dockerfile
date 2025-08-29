FROM ghcr.io/astral-sh/uv:python3.13-bookworm AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /project

RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml uv.lock /project/
RUN uv sync --frozen --no-cache

FROM base AS app
COPY src /project/src
COPY alembic.ini /project/
RUN chmod +x /project/src/entrypoint.sh
EXPOSE 8000
ENTRYPOINT ["/project/src/entrypoint.sh"]

FROM base AS tests
COPY tests /project/tests
WORKDIR /project
CMD ["uv", "run", "--with", "pytest,pytest-asyncio,httpx", "pytest", "-q", "/project/tests"]
