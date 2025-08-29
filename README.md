fastapi-template

A minimal FastAPI + TaskIQ + SQLAlchemy/Alembic template.
- Service: single /health endpoint.
- Tasks: background worker with a heartbeat task (every minute) using Redis broker.
- Database: async SQLAlchemy with Alembic migrations.
- Docker: ready-to-run compose for service, Postgres, Redis, and tasks.

Migrations note
To enable Alembic autogeneration, import your ORM models inside Alembic env.py so that Base.metadata is aware of them. For example, add imports like:

from src.db.models.user import User  # ensure models are imported

This line must be in src/db/migrations/env.py (or import a module that imports all models) before setting target_metadata = Base.metadata.
