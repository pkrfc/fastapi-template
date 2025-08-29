import sys
from functools import lru_cache
from typing import Any

from loguru import logger


class ConsoleLogger:
    def __init__(self, level: str = "DEBUG"):
        """Create and configure a console logger.

        Args:
            level: Logging level (default is "DEBUG").
        """
        logger.remove()
        logger.add(
            sys.stdout,
            level=level,
            colorize=True,
            format="<green>{time:HH:mm:ss}</green> | "
            "<level>{level: <8}</level> | "
            "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
            "<level>{message}</level>",
        )
        self.logger = logger

    def get_logger(self):
        """Return configured console logger instance.

        Returns:
            Any: loguru logger instance.
        """
        return self.logger


@lru_cache
def get_console_logger() -> Any:
    """Cached console logger provider in get_* style.

    Returns:
        Any: Configured loguru logger for console output.
    """
    return ConsoleLogger().get_logger()
