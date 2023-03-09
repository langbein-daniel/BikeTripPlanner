# BikeTripPlanner

Get your journey-planner instance up and running with Docker Compose.

## Build data images

### GTFS data

```shell
sudo docker compose -f build-data.yml build --pull gtfs-data
```

### OSM excerpt

```shell
sudo docker compose -f build-data.yml build --pull osm-excerpt
```

### Background map (Tileserver GL)

```shell
sudo docker compose -f build-tilemaker.yml build --pull tilemaker
# Don't `--pull` as we are using the previously built `tilemaker`.
sudo docker compose build tileserver-gl
```

### Routing (OpenTripPlanner)

```shell
# Don't `--pull` as we are using the previously built `osm-excerpt`.
sudo docker compose build opentripplanner
```

### Geocoder (Pelias)

```shell
# Set shell variables from `.env`.
export "$(cat .env | grep '^BUILD_NAME=')" 
export "$(cat .env | grep '^PELIAS_BUILD_DIR=')" 
# Create temporary Pelias data directory.
mkdir -p "${PELIAS_BUILD_DIR}/data/"{elasticsearch,openstreetmap,gtfs}
# Start Elasticsearch and wait until healthy.
sudo docker compose -f build-pelias.yml up -d --wait elasticsearch
# Initialize Elasticsearch.
sudo docker compose -f build-pelias.yml run --rm schema ./bin/create_index
# Download, prepare and import data:
sudo docker run --rm --entrypoint cat ${BUILD_NAME}-osm-excerpt /data/extract.osm.pbf > "${PELIAS_BUILD_DIR}/data/openstreetmap/extract.osm.pbf"
sudo docker run --rm --entrypoint cat ${BUILD_NAME}-gtfs-data   /data/gtfs.zip        > "${PELIAS_BUILD_DIR}/data/gtfs/gtfs.zip"
sudo docker compose -f build-pelias.yml run --rm whosonfirst   ./bin/download
sudo docker compose -f build-pelias.yml run --rm polylines     ./docker_extract.sh
sudo docker compose -f build-pelias.yml run --rm placeholder   ./cmd/extract.sh
sudo docker compose -f build-pelias.yml run --rm placeholder   ./cmd/build.sh
sudo docker compose -f build-pelias.yml run --rm interpolation ./docker_build.sh
sudo docker compose -f build-pelias.yml run --rm whosonfirst   ./bin/start
sudo docker compose -f build-pelias.yml run --rm openstreetmap ./bin/start
sudo docker compose -f build-pelias.yml run --rm polylines     ./bin/start
sudo docker compose -f build-pelias.yml run --build --rm gtfs  ./bin/start
# Stop and remove intermediate containers.
sudo docker compose -f build-pelias.yml down
# Build final Pelias containers.
sudo docker compose build
# Remove temporary data directory.
#sudo rm -r "${PELIAS_BUILD_DIR}/data"
```

### Web UI (Digitransit)

```shell
sudo docker compose build --pull digitransit-ui
```

## Startup - Local development setup

The `digitransit-ui` service has to be configured with the URLs of three dependent services.
Both, the client (webbrowser of a user) and the server (the `digitransit-ui` service itself) connect to these URLs.

As docker isolates the services from the host network, the `digitransit-ui` service can't e.g. connect to the `api` service through `localhost`. Instead, the hostname of the `api` service has to be used.

To be able to test the Digitransit UI locally in your browser, add the following three entries to `/etc/hosts`:

```
127.0.0.1 opentripplanner
127.0.0.1 tileserver-gl
127.0.0.1 api
```

Start all services and wait for them to be healthy:

```shell
sudo docker compose up -d --wait
```

## Shutdown

```shell
sudo docker compose down
```
