#!/bin/bash
set -e

CERT_FILE=/etc/ssl/certs/server.crt
KEY_FILE=/etc/ssl/private/server.key

# Generate self-signed certificate if not present
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo "Generating self-signed certificate..."
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=localhost"
fi

# Start NGINX in foreground (PID 1)
nginx -g "daemon off;"
