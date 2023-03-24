# BikeTripPlanner

Get your journey-planner instance up and running with Docker Compose.

A demo instance covering the area of the German transport association
VGN is available at [https://biketripplanner.privacy1st.de/](https://biketripplanner.privacy1st.de/).

![nuremberg-bike-and-ride.png](screenshot-nuremberg-bike-and-ride.png)

## Configuration

Go through [.env](.env) and adjust the values as desired.

## Build data images

The following sections provide additional information about the individual build steps. There is also a [Makefile](Makefile) to accomplish the same.

TLDR: Just run `make` to build all Docker images.

### GTFS data

If the GTFS data set is valid and contains bicycle information, run the following:

```shell
sudo docker compose -f build-data.yml build --pull gtfs-data
```

If you need to modify the GTFS data first, then have a look at the following example instead:

* The GTFS zip file from the VGN does not contain the `bikes_allowed` column and some values of the CSV files are not properly quoted/escaped.
* We want to modify the GTFS data first before creating the `gtfs-data` image.
* This is done with the following two commands:

```shell
sudo docker compose -f build-data-vgn.yml build --pull gtfs-data-raw
sudo docker compose -f build-data-vgn.yml build gtfs-data
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
export "$(grep '^BUILD_NAME=' < .env)"
export "$(grep '^PELIAS_BUILD_DIR=' < .env)"
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
sudo docker compose build api libpostal placeholder interpolation pip elasticsearch
# Remove temporary data directory.
#sudo rm -r "${PELIAS_BUILD_DIR}/data"
```

### Web UI (Digitransit)

```shell
sudo docker compose build --pull digitransit-ui
```

## Test on local machine

### Startup

Start all services and wait for them to be healthy:

```shell
sudo docker compose up -d --wait
```

### Verify healthcheck output

* https://docs.docker.com/engine/reference/builder/#healthcheck

The first 4096 bytes of a containers healthcheck output can be viewed with:

```shell
CONTAINER=libpostal && \
CONTAINER_ID="$(sudo docker compose ps -q "${CONTAINER}")" && \
sudo docker inspect "${CONTAINER_ID}" | jq '.[].State.Health.Log[].Output'
```

### Shutdown

```shell
sudo docker compose down
```

## Deployment

### Publish images

Tag and push the locally built images to a docker container registry.

```shell
./publish.sh
```

### Example deployment with Let's Encrypt certificates

```shell
cd deployment
sudo docker compose up -d --wait
```
