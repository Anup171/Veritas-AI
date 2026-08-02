# syntax=docker/dockerfile:1

FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Copy dependency declarations first so this layer is reused when only source
# files change.
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Create a dedicated account. The app is the only process that runs at
# container runtime and it does not need root privileges.
RUN groupadd --gid 10001 appgroup \
    && useradd --uid 10001 --gid appgroup --create-home --shell /usr/sbin/nologin appuser \
    && install --directory --owner=appuser --group=appgroup /app/outputs /app/.cache /app/.files

# The runtime needs the application package, UI configuration, and its entry
# points. Runtime configuration, cached research data, and generated reports
# stay outside the image.
COPY --chown=appuser:appgroup src ./src
COPY --chown=appuser:appgroup .chainlit/config.toml ./.chainlit/config.toml
COPY --chown=appuser:appgroup app.py main.py chainlit.md ./
COPY --chown=appuser:appgroup docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod 755 /usr/local/bin/docker-entrypoint

EXPOSE 8000

USER appuser

ENTRYPOINT ["docker-entrypoint"]
CMD ["chainlit", "run", "app.py", "--host", "0.0.0.0", "--port", "8000"]
