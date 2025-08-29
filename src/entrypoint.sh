#!/bin/sh
set -e

echo "Starting migrations..."
uv run alembic upgrade head

echo "Starting server..."
exec uv run uvicorn src.main:app --host 0.0.0.0 --port 8000 --no-access-log
