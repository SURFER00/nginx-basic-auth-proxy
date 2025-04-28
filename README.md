# Basic Auth Proxy

A lightweight Docker image that adds HTTP Basic Authentication to any web service that doesn't have built-in authentication capabilities.

## Overview

This project provides a simple NGINX-based proxy that sits in front of your services and requires basic authentication before allowing access. It's designed to be minimal, configurable, and easy to use in Docker environments.

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│                            DOCKER STACK                             │
│                                                                     │
│   ┌─────────────────────────┐        ┌─────────────────────────┐    │
│   │                         │        │                         │    │
│   │     Basic Auth Proxy    │        │      Target Service     │    │
│   │    (NGINX + htpasswd)   │◄──────►│   (cAdvisor, etc.)      │    │
│   │                         │        │                         │    │
│   └─────────────┬───────────┘        └─────────────────────────┘    │
│                 │                                                   │
└─────────────────┼───────────────────────────────────────────────────┘
                  │ HTTP Basic Auth
                  │ (BASIC_AUTH_USERNAME / BASIC_AUTH_PASSWORD)
                  ▼
               8080/tcp
```

## Features

- 🔒 HTTP Basic Authentication protection for any service
- 🔌 WebSocket support for compatible applications
- 🐳 Minimal Docker image based on NGINX Alpine
- ⚙️ Simple configuration via environment variables
- 🔄 Designed for Docker Compose and Swarm environments
- 📦 Lightweight and low resource usage

## Quick Start

### Building the Image

```bash
# Clone this repository
git clone https://github.com/yourusername/basic-auth-proxy.git
cd basic-auth-proxy

# Build the Docker image
docker build -t basic-auth-proxy .
```

### Basic Usage

```bash
docker run -d \
  --name my-protected-service \
  -e BASIC_AUTH_USERNAME=admin \
  -e BASIC_AUTH_PASSWORD=secure_password \
  -e PROXY_PASS=http://target-service:8080 \
  -p 8080:80 \
  basic-auth-proxy
```

Now you can access your service at http://localhost:8080 and will be prompted for the username and password you specified.

## Docker Compose Example

Here's a complete example for protecting cAdvisor:

```yaml
services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - backend
    deploy:
      restart_policy:
        condition: on-failure

  cadvisor-auth:
    image: ghcr.io/surfer00/nginx-basic-auth-proxy:latest
    environment:
      - BASIC_AUTH_USERNAME=admin
      - BASIC_AUTH_PASSWORD=your_secure_password
      - PROXY_PASS=http://cadvisor:8080
      - CLIENT_MAX_BODY_SIZE=100m
    networks:
      - backend
      - frontend
    ports:
      - "8080:80"
    depends_on:
      - cadvisor
    deploy:
      restart_policy:
        condition: on-failure

networks:
  frontend:
    external: true  # Connect to your reverse proxy network
  backend:
    driver: overlay
    internal: true  # Only internal communication
```

## Configuration Options

The following environment variables can be used to configure the proxy:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `BASIC_AUTH_USERNAME` | Username for Basic Auth | (unset) | yes
| `BASIC_AUTH_PASSWORD` | Password for Basic Auth | (unset) | yes
| `PROXY_PASS` | URL of the service to proxy to | (unset) | yes
| `CLIENT_MAX_BODY_SIZE` | Maximum allowed size of client requests | `1m` | no
| `PROXY_READ_TIMEOUT` | Defines a timeout for reading a response from the proxied server | `60s` | no

## Using with a Reverse Proxy

This proxy works seamlessly as part of a larger architecture with an external reverse proxy. The typical flow would be:

```
User → External Reverse Proxy → [Docker Stack] → Basic Auth Proxy → Target Service
```

This setup allows you to:
- Use a single entry point for all your services
- Implement TLS termination at your external reverse proxy
- Add basic authentication only to services that need it
- Isolate services within internal Docker networks

## Security Considerations

- Change the default username and password
- This proxy uses HTTP Basic Authentication, which sends credentials in base64 encoding (not encrypted)
- For production use, this proxy should be behind a TLS-terminating reverse proxy

## Files

This project consists of three main files:

- `Dockerfile`: Builds the Docker image
- `nginx.conf`: Template for the NGINX configuration
- `entrypoint.sh`: Script that configures NGINX at startup
