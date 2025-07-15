#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "WARNING: This will remove all generated secrets, environment files, containers, volumes, Docker images, and networks."
read -p "Are you sure you want to continue? [y/N]: " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Reset cancelled."
    exit 1
fi

echo "Resetting SceneScape environment..."

# Stop and remove containers, networks, and volumes
docker compose down --remove-orphans -v

# Remove Docker networks created by Compose (except default bridge/host/none)
docker network ls --format '{{.Name}}' | grep scenescape | xargs -r docker network rm

# Remove generated secrets and related files
SECRETS_DIR="src/secrets"
rm -rf ${SECRETS_DIR}/ca
rm -rf ${SECRETS_DIR}/certs
rm -rf ${SECRETS_DIR}/django
rm -f  ${SECRETS_DIR}/supass
rm -f  ${SECRETS_DIR}/controller.auth
rm -f  ${SECRETS_DIR}/browser.auth

# Remove .env files
rm -f src/.env

# Remove bind mount volumes if using bind mounts
rm -rf volumes/db volumes/media volumes/migrations

# Remove dlstreamer pipeline server bind mount folders if present
rm -rf src/dlstreamer-pipeline-server/videos
rm -rf src/dlstreamer-pipeline-server/models
rm -rf src/dlstreamer-pipeline-server/user_scripts

# Remove any orphaned Docker volumes (including named tmpfs volumes)
docker volume prune -f

# Remove specific named volumes for dlstreamer if they exist
docker volume rm dlstreamer-pipeline-server-pipeline-root dlstreamer-pipeline-server-tmp 2>/dev/null

for img in $(docker compose config | grep 'image:' | awk '{print $2}' | sort -u); do
    read -p "Remove image $img? [y/N]: " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        docker rmi -f "$img"
    fi
done

echo "Reset complete."