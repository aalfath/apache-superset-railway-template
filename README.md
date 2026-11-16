[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/apache-superset-1?utm_medium=integration&utm_source=button&utm_campaign=apache-superset)

# Apache Superset on Railway

A one-click Railway template for [Apache Superset](https://superset.apache.org/), the open-source data exploration and dashboard platform.

## What it deploys

| Service | Source | Purpose |
|---|---|---|
| **Superset** | this repo (`Dockerfile`) | Web app and API, served by gunicorn on `PORT` (8088), health check `/health` |
| **Postgres** | Railway PostgreSQL | Superset's metadata database: users, roles, databases, datasets, charts, dashboards, saved queries |
| **Redis** | Railway Redis | Chart and query result cache, rate-limit storage |

- **Superset 6.1.0**, official image `apache/superset:6.1.0@sha256:16b50bbef6648912a79e3293d418fefa743ce555d36c5af6b85d859119ed7f88`.
- The official image ships without database drivers. This repo adds `psycopg2-binary` 2.9.13 (PostgreSQL), `PyMySQL` 1.2.4 (MySQL/MariaDB, `mysql+pymysql://`) and `clickhouse-connect` 1.12.0 (ClickHouse, `clickhousedb://`).
- On every start, `start.sh` runs `superset db upgrade`, creates the first admin user if it doesn't exist yet, runs `superset init`, then starts gunicorn.
- `superset_config.py` reads everything from environment variables and turns on `ENABLE_PROXY_FIX`, since Railway terminates HTTPS in front of the service.

## Variables (Superset service)

| Variable | Default | Notes |
|---|---|---|
| `PORT` | `8088` | Port gunicorn listens on |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Metadata database |
| `REDIS_URL` | `${{Redis.REDIS_URL}}` | Cache and rate limits. Remove it to run without Redis |
| `SUPERSET_SECRET_KEY` | generated | Signs sessions and encrypts stored database passwords. **Never change it after the first deploy**, or saved connection passwords can't be decrypted |
| `ADMIN_USERNAME` | `admin` | First admin user, created on the first start only |
| `ADMIN_PASSWORD` | generated | Password of that admin. Read it in the service's Variables tab. Changing it later has no effect: change the password from your user profile in Superset instead |
| `ADMIN_EMAIL` | `admin@example.com` | Email of the first admin |

Optional: `SERVER_WORKER_AMOUNT` (gunicorn workers, default 2), `SERVER_THREADS_AMOUNT` (default 20), `GUNICORN_TIMEOUT` (seconds, default 120), `CACHE_DEFAULT_TIMEOUT` (seconds, default 86400).

## Not included

- **Celery worker and beat** (Alerts & Reports, scheduled email reports, async SQL Lab queries). Add two more services from this repo with the start command `celery --app=superset.tasks.celery_app:app worker` and `celery --app=superset.tasks.celery_app:app beat`, plus a `CELERY_CONFIG` in `superset_config.py`. See the [Superset docs](https://superset.apache.org/docs/configuration/async-queries-celery).
- **Example data** (`superset load_examples`).
- More database drivers: add them to the `uv pip install` line in the `Dockerfile` ([list of drivers](https://superset.apache.org/docs/configuration/databases)).

## Updates

The Superset service builds from this repo's `main` branch. When a new Superset release is tested here, the pin in the `Dockerfile` is bumped and the change is described in [CHANGELOG.md](CHANGELOG.md). Railway then shows an "update available" notice to everyone who deployed the template, and you choose when to apply it. Read the changelog first: Superset runs its database migrations on start, and they can't be rolled back without a database backup.

## License

Apache Superset is licensed under the Apache License 2.0. This wrapper is offered under the same license.
