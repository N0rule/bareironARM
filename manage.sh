#!/bin/bash

case "$1" in
  build)
    echo "Building bareironARM Docker image..."
    docker compose build --no-cache
    ;;
  start)
    echo "Starting server..."
    docker compose up -d
    ;;
  stop)
    echo "Stopping server..."
    docker compose down
    ;;
  restart)
    echo "Restarting with fresh build..."
    docker compose down
    docker compose build --no-cache
    docker compose up -d
    ;;
  rebuild)
    echo "Rebuilding binary and Docker image..."
    ./build.sh --no-run
    docker compose down
    docker compose build --no-cache
    docker compose up -d
    ;;
  logs)
    docker compose logs -f
    ;;
  shell)
    docker compose exec bareiron /bin/sh
    ;;
  *)
    echo "Usage: $0 {build|start|stop|restart|rebuild|logs|shell}"
    echo "  build   - Build Docker image only"
    echo "  start   - Start server"
    echo "  stop    - Stop server"
    echo "  restart - Rebuild image and restart"
    echo "  rebuild - Rebuild binary + image and restart"
    echo "  logs    - Show server logs"
    echo "  shell   - Open shell in container"
    ;;
esac
