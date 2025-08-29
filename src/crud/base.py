from typing import Generic, TypeVar

from pydantic import BaseModel

from src.db.models.db_base import Base

ModelType = TypeVar("ModelType", bound=Base)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)


class CRUDBase(Generic[ModelType, CreateSchemaType]):
    """Base CRUD layer for models."""

    def __init__(self, model: type[ModelType]) -> None:
        """Initialize CRUD.

        Args:
            model: ORM model class.
        """
        self.model = model
