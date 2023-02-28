# BikeTripPlanner

Get your journey-planner instance up and running with Docker Compose.

## GTFS data

```shell
sudo docker compose build --pull gtfs-data
```

## OSM excerpt

```shell
sudo docker compose build --pull osm-excerpt
```

## Background map

```shell
sudo docker compose build --pull tilemaker
# Don't `--pull` as we are using the local image created by the previous step.
sudo docker compose build tile-data
```

## Geocoder (Pelias)

```shell
# Set shell variables from `.env`.
export "$(cat .env | grep '^NAME=')" 
export "$(cat .env | grep '^PELIAS_BUILD_DIR=')" 
# Create temporary Pelias data directory.
mkdir -p "${PELIAS_BUILD_DIR}/data/"{elasticsearch,openstreetmap,gtfs}
# Start Elasticsearch and wait until healthy.
sudo docker compose -f pelias-build.yml up -d --wait elasticsearch
# Initialize Elasticsearch.
sudo docker compose -f pelias-build.yml run --rm schema ./bin/create_index
# Download, prepare and import data:
sudo docker run --rm --entrypoint cat ${NAME}-osm-excerpt /data/extract.osm.pbf > "${PELIAS_BUILD_DIR}/data/openstreetmap/extract.osm.pbf"
sudo docker run --rm --entrypoint cat ${NAME}-gtfs-data   /data/gtfs.zip        > "${PELIAS_BUILD_DIR}/data/gtfs/gtfs.zip"
sudo docker compose -f pelias-build.yml run --rm whosonfirst   ./bin/download
sudo docker compose -f pelias-build.yml run --rm polylines     ./docker_extract.sh
sudo docker compose -f pelias-build.yml run --rm placeholder   ./cmd/extract.sh
sudo docker compose -f pelias-build.yml run --rm placeholder   ./cmd/build.sh
sudo docker compose -f pelias-build.yml run --rm interpolation ./docker_build.sh
sudo docker compose -f pelias-build.yml run --rm whosonfirst   ./bin/start
sudo docker compose -f pelias-build.yml run --rm openstreetmap ./bin/start
sudo docker compose -f pelias-build.yml run --rm polylines     ./bin/start
sudo docker compose -f pelias-build.yml run --build --rm gtfs  ./bin/start
# Stop and remove intermediate containers.
sudo docker compose -f pelias-build.yml down
# Build final Pelias containers.
sudo docker compose build
# Remove temporary data directory.
#sudo rm -r "${PELIAS_BUILD_DIR}/data"
```

## Startup

```shell
sudo docker compose up -d --wait
```
