#!/usr/bin/env sh
set -e

GTFS_DIR=/data/gtfs
if [ ! -f "${GTFS_DIR}/gtfs.zip" ]; then
    echo "Nothing to import. ${GTFS_DIR}/gtfs.zip does not exist."
    exit 0
fi
unzip -o -d "${GTFS_DIR}" "${GTFS_DIR}/gtfs.zip"

node import.js -d "${GTFS_DIR}"
rm "${GTFS_DIR}"/*.txt
