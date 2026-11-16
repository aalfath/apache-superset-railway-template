"""Superset configuration for the Railway template.

Everything comes from environment variables, so the image stays the same for
every deployer. Add your own settings below, or set them as variables.
"""
import os


def _env(name, default=None):
    value = os.environ.get(name)
    return value if value not in (None, "") else default


SECRET_KEY = _env("SUPERSET_SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError("SUPERSET_SECRET_KEY must be set (a long random string).")

_database_url = _env("DATABASE_URL")
if not _database_url:
    raise RuntimeError("DATABASE_URL must point at the PostgreSQL metadata database.")
if _database_url.startswith("postgres://"):
    _database_url = "postgresql://" + _database_url[len("postgres://"):]
SQLALCHEMY_DATABASE_URI = _database_url

# Railway terminates TLS in front of the service and sends X-Forwarded-* headers.
ENABLE_PROXY_FIX = True

# Redis: chart and query result cache, plus rate-limit storage.
_redis_url = _env("REDIS_URL")
if _redis_url:
    _redis_cache = {
        "CACHE_TYPE": "RedisCache",
        "CACHE_REDIS_URL": _redis_url,
        "CACHE_DEFAULT_TIMEOUT": int(_env("CACHE_DEFAULT_TIMEOUT", "86400")),
    }
    CACHE_CONFIG = {**_redis_cache, "CACHE_KEY_PREFIX": "superset_cache_"}
    DATA_CACHE_CONFIG = {**_redis_cache, "CACHE_KEY_PREFIX": "superset_data_"}
    RATELIMIT_STORAGE_URI = _redis_url
