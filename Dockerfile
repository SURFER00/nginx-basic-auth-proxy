FROM nginx:1.28.1-alpine-slim

RUN apk add --no-cache apache2-utils

COPY entrypoint.sh /entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf.template

RUN chmod +x /entrypoint.sh

ENV CLIENT_MAX_BODY_SIZE=1m
ENV PROXY_READ_TIMEOUT=60s

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
