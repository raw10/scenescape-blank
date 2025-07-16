#!/bin/bash

docker run --rm -ti \
    -e http_proxy -e https_proxy -e no_proxy \
    -v $(pwd)/init.sh:/init.sh \
    -v $(pwd)/src:/src \
    docker.io/library/python:3.12 bash init.sh

# Append contents of src/.env to project root .env (do not overwrite)
if [ -f src/.env ]; then
    # Remove existing UID/GID lines to avoid duplicates
    sed -i '/^UID=/d' .env 2>/dev/null || true
    sed -i '/^GID=/d' .env 2>/dev/null || true
    cat src/.env >> .env
    echo "Appended src/.env to .env in project root."
else
    echo "Warning: src/.env not found. UID/GID may not be set for Docker Compose."
fi

# Convert all downloaded mp4 videos to ts format (do not delete originals by default)
VIDEO_DIR="src/dlstreamer-pipeline-server/videos"
echo "Converting videos in $VIDEO_DIR to TS format..."
if [ -d "$VIDEO_DIR" ]; then
    ./src/dlstreamer-pipeline-server/convert_video_to_ts.sh "$VIDEO_DIR"
fi

echo "SceneScape initialization complete."

# Prompt to start the environment
read -p "Would you like to start the environment now with 'docker compose up -d'? [y/N]: " start_now
if [[ "$start_now" =~ ^[Yy]$ ]]; then
    docker compose up -d
    echo "Environment started. You can check running containers with 'docker compose ps'."
else
    echo "You can start the environment anytime by running:"
    echo "  docker compose up -d"
    echo "To check running containers, use:"
    echo "  docker compose ps"
fi