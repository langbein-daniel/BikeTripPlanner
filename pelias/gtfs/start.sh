#!/usr/bin/env sh
set -e

GTFS_DIR=/data/gtfs
if [ ! -f "${GTFS_DIR}/gtfs.zip" ]; then
    echo "Nothing to import. ${GTFS_DIR}/gtfs.zip does not exist."
    exit 0
fi
unzip -o -d "${GTFS_DIR}" "${GTFS_DIR}/gtfs.zip"

# In `documentStream.js:
#   sourceName = 'GTFS' + prefix
# This results in e.g. `gtfs1`.
# This is passed to Pelias during import,
# so Pelias will get an additional source named `gtfs1`.
node import.js -d "${GTFS_DIR}" --prefix "1"
rm "${GTFS_DIR}"/*.txt
