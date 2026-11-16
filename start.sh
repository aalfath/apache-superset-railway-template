#!/usr/bin/env bash
# Start Apache Superset on Railway: migrate, create the first admin, sync roles, serve.
set -euo pipefail

PORT="${PORT:-8088}"
ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"

if [ -z "${ADMIN_PASSWORD:-}" ]; then
  echo "ADMIN_PASSWORD must be set." >&2
  exit 1
fi

echo "[railway] Applying database migrations"
superset db upgrade

if superset fab list-users 2>/dev/null | grep -q "username:${ADMIN_USERNAME} "; then
  echo "[railway] Admin user '${ADMIN_USERNAME}' already exists, leaving it as it is"
else
  echo "[railway] Creating admin user '${ADMIN_USERNAME}'"
  superset fab create-admin \
    --username "${ADMIN_USERNAME}" \
    --firstname Admin \
    --lastname User \
    --email "${ADMIN_EMAIL}" \
    --password "${ADMIN_PASSWORD}"
fi

echo "[railway] Syncing roles and permissions"
superset init

echo "[railway] Starting Superset on port ${PORT}"
exec gunicorn \
  --bind "[::]:${PORT}" \
  --access-logfile - \
  --error-logfile - \
  --workers "${SERVER_WORKER_AMOUNT:-2}" \
  --worker-class gthread \
  --threads "${SERVER_THREADS_AMOUNT:-20}" \
  --timeout "${GUNICORN_TIMEOUT:-120}" \
  --keep-alive 2 \
  --limit-request-line 0 \
  --limit-request-field_size 0 \
  "superset.app:create_app()"
