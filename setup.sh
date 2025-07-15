#!/bin/bash

docker run --rm -ti \
    -e http_proxy -e https_proxy -e no_proxy \
    -v $(pwd)/init.sh:/init.sh \
    -v $(pwd)/src:/src \
    docker.io/library/python:3.12 bash init.sh

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