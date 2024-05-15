#!/bin/sh

# Configure defaults
# Run API server

if [ -n "${DEBUG}" ]; then set -eux; fi

echo "Backend endpoint address http://${DEVIN_IP}:${DEVIN_API_PORT}"

UI_PORT="${UI_HTTP_PORT}"

if [ -n "${SECURE_MODE}" ]; then
    UI_PORT="${UI_HTTPS_PORT}"
fi

export UI_PORT=${UI_PORT}

if [ -n "${SECURE_MODE}" ]; then
    echo "Starting frontend server on http://0.0.0.0:${UI_PORT}"
    vite --config vite.config.js --host 0.0.0.0
else
    echo "Starting frontend server on https://0.0.0.0:${UI_PORT}"
    vite --config vite.config.js --host 0.0.0.0 --clearScreen false
fi
