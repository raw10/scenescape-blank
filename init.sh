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

# Get a sample video if not already present
if [ ! -d "${SOURCE}/dlstreamer-pipeline-server/videos" ] || [ -z "$(find "${SOURCE}/dlstreamer-pipeline-server/videos" -type f -name "*.mp4" 2>/dev/null)" ]; then
  VIDEO_URL="https://github.com/open-edge-platform/scenescape/blob/v1.3.0/sample_data"
  VIDEOS=("apriltag-cam3.mp4")
  VIDEO_DIR="${SOURCE}/dlstreamer-pipeline-server/videos"

  mkdir -p "${VIDEO_DIR}"
  for VIDEO in "${VIDEOS[@]}"; do
    echo "Downloading ${VIDEO} from ${VIDEO_URL}${VIDEO}..."
    curl -v -L "${VIDEO_URL}${VIDEO}?raw=true" -o "${VIDEO_DIR}/${VIDEO}"
    if [ ! -f "${VIDEO_DIR}/${VIDEO}" ]; then
        echo "Error: Failed to download ${VIDEO} to ${VIDEO_DIR}/${VIDEO}"
        ls -l "${VIDEO_DIR}"
        exit 1
    else
        echo "Downloaded ${VIDEO} successfully."
    fi
  done
fi
