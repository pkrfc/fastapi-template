from taskiq import TaskiqScheduler
from taskiq.schedule_sources import LabelScheduleSource
from taskiq_redis import RedisAsyncResultBackend, RedisScheduleSource, RedisStreamBroker

from src.config import get_const_settings, get_settings
from src.logger import get_console_logger

settings = get_settings()
const_settings = get_const_settings()

result_backend = RedisAsyncResultBackend(
    redis_url=settings.REDIS_URL,
    result_ex_time=const_settings.REDIS_RESULT_EX_TIME,
)
redis_source = RedisScheduleSource(settings.REDIS_URL)

broker = RedisStreamBroker(
    url=settings.REDIS_URL,
    xread_count=const_settings.REDIS_XREAD_COUNT,
).with_result_backend(result_backend)

scheduler = TaskiqScheduler(
    broker=broker,
    sources=[
        LabelScheduleSource(broker),
    ],
)


@broker.task(
    schedule=[{"cron": "*/1 * * * *", "args": []}],
)
async def heartbeat_task() -> None:
    """Every minute writes a log line to confirm the worker is alive."""
    logger = get_console_logger()
    logger.info("Heartbeat: worker is alive")
    return
