#!/bin/sh
set -e

htpasswd -bc /etc/nginx/.htpasswd "$BASIC_AUTH_USERNAME" "$BASIC_AUTH_PASSWORD" > /dev/null 2> /dev/null
envsubst '${CLIENT_MAX_BODY_SIZE} ${PROXY_PASS}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"