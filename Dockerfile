# Apache Superset 6.1.0 for Railway.
# Official image, pinned by version and digest. Bump both together.
FROM apache/superset:6.1.0@sha256:16b50bbef6648912a79e3293d418fefa743ce555d36c5af6b85d859119ed7f88

USER root

# The official image ships without database drivers. Add the PostgreSQL driver
# (needed for the metadata database) and two common warehouse drivers.
RUN uv pip install --no-cache --python /app/.venv/bin/python \
        psycopg2-binary==2.9.13 \
        PyMySQL==1.2.4 \
        clickhouse-connect==1.12.0

COPY superset_config.py /app/pythonpath/superset_config.py
COPY start.sh /app/railway-start.sh
RUN chmod 0644 /app/pythonpath/superset_config.py && chmod 0755 /app/railway-start.sh

USER superset
EXPOSE 8088
CMD ["/app/railway-start.sh"]
