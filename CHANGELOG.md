# Changelog

## 6.1.0 (2026-11-16)

- First release of the template: Apache Superset 6.1.0 (`apache/superset:6.1.0@sha256:16b50bbef6648912a79e3293d418fefa743ce555d36c5af6b85d859119ed7f88`) with Railway PostgreSQL for metadata and Railway Redis for caching.
- Adds `psycopg2-binary` 2.9.13, `PyMySQL` 1.2.4 and `clickhouse-connect` 1.12.0 to the image.
- Start script runs migrations, creates the first admin from `ADMIN_USERNAME`/`ADMIN_PASSWORD`, syncs roles and serves on `PORT` with gunicorn.
