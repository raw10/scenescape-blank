#!/bin/sh

# Copyright (C) 2024 Intel Corporation
#
# This software and the related documents are Intel copyrighted materials,
# and your use of them is governed by the express license under which they
# were provided to you ("License"). Unless the License provides otherwise,
# you may not use, modify, copy, publish, distribute, disclose or transmit
# this software or the related documents without Intel's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the License.

# script to convert mp4 files in sample-data directory
# to ts files so that gstreamer pipeline can keep running the files
# in infinite loop without having to deallocate buffers

# Usage: ./convert_video_to_ts.sh [directory] [--delete]
# Converts all .mp4 files in the given directory to .ts files using Dockerized ffmpeg.
# If --delete is provided, deletes the original .mp4 after successful conversion.

docker pull intel/intel-optimized-ffmpeg:latest

TARGET_DIR="${1:-$(pwd)}"
TARGET_DIR="$(realpath "$TARGET_DIR")"
DELETE_OLD=0
if [ "$2" = "--delete" ]; then
    DELETE_OLD=1
fi

FFMPEG_DIR="/app/data"
FFMPEG_IMAGE="intel/intel-optimized-ffmpeg:latest"
DOCKER_RUN_CMD_PREFIX="docker run --rm -v ${TARGET_DIR}:${FFMPEG_DIR} --entrypoint /bin/sh ${FFMPEG_IMAGE}"

for mfile in "${TARGET_DIR}"/*.mp4; do
    [ -e "$mfile" ] || continue
    basefile=$(basename -s .mp4 "$mfile")
    tsfile="${TARGET_DIR}/${basefile}.ts"
    echo "Converting $mfile to $tsfile"
    if [ -f "$tsfile" ]; then
        echo "Skipping $basefile as $tsfile already exists"
    else
        ffmpegcmd="/opt/build/bin/ffmpeg -i ${FFMPEG_DIR}/${basefile}.mp4 -c copy ${FFMPEG_DIR}/${basefile}.ts"
        cmd="$DOCKER_RUN_CMD_PREFIX -c '$ffmpegcmd'"
        if eval $cmd; then
            echo "Conversion successful: $tsfile"
            if [ $DELETE_OLD -eq 1 ]; then
                echo "Deleting original file: $mfile"
                rm -f "$mfile"
            fi
        else
            echo "Conversion failed for $mfile"
        fi
    fi
done

