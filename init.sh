#!/bin/bash

echo "Starting SceneScape initialization..."

SOURCE="src"
bash ${SOURCE}/secrets/generate_secrets.sh

if [ ! -f .env ]; then
  touch ${SOURCE}/.env
fi

USER_UID=$(stat -c '%u' "${SOURCE}"/* | sort -rn | head -1)
USER_GID=$(stat -c '%g' "${SOURCE}"/* | sort -rn | head -1)

# Write .env to the src directory so it persists on the host
echo "UID=$USER_UID" > ${SOURCE}/.env
echo "GID=$USER_GID" >> ${SOURCE}/.env

# Remove existing UID/GID lines from .env
sed -i '/^UID=/d' .env 2>/dev/null || true
sed -i '/^GID=/d' .env 2>/dev/null || true

# Append contents of src/.env to project root .env (do not overwrite other settings)
if [ -f src/.env ]; then
    cat src/.env >> .env
    echo "Appended src/.env to .env in project root."
else
    echo "Warning: src/.env not found. UID/GID may not be set for Docker Compose."
fi

# Get a sample video if not already present
if [ ! -d "${SOURCE}/dlstreamer-pipeline-server/videos" ] || [ -z "$(find "${SOURCE}/dlstreamer-pipeline-server/videos" -type f -name "*.mp4" 2>/dev/null)" ]; then
  VIDEO_URL="https://github.com/intel-iot-devkit/sample-videos/blob/master/" 
  VIDEOS=("car-detection.mp4")
  VIDEO_DIR="${SOURCE}/dlstreamer-pipeline-server/videos"

  mkdir -p "${VIDEO_DIR}"
  for VIDEO in "${VIDEOS[@]}"; do
    echo "Downloading ${VIDEO} from ${VIDEO_URL}${VIDEO}..."
    curl -L "${VIDEO_URL}${VIDEO}?raw=true" -o "${VIDEO_DIR}/${VIDEO}"
    if [ ! -f "${VIDEO_DIR}/${VIDEO}" ]; then
        echo "Error: Failed to download ${VIDEO} to ${VIDEO_DIR}/${VIDEO}"
        ls -l "${VIDEO_DIR}"
        exit 1
    else
        echo "Downloaded ${VIDEO} successfully."
    fi
  done
fi
