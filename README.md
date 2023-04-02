# BikeTripPlanner

Get your journey-planner instance up and running with Docker Compose.

A demo instance covering the area of the German transport association
VGN is available at [https://biketripplanner.privacy1st.de/](https://biketripplanner.privacy1st.de/).

![nuremberg-bike-and-ride.png](screenshot-nuremberg-bike-and-ride.png)

## Configuration

Go through [.env](.env) and adjust the values as desired.

Important parts are:
- Bounding box describing a rectangular geographical area
- Link to OpenStreetMap region covering the bounding box
- Link to GTFS feed providing transit data

In addition to the default configuration for the area of the VGN transport association, there is a `.env` file for [Finland](examples/finnland/.env). Just overwrite [.env](.env) with it to give it a try.

## Build data images

The following sections provide additional information about the individual build steps. There is also a [Makefile](Makefile) to accomplish the same.

TLDR: Just run `make` to build all Docker images.

### GTFS data

If the GTFS data set is valid and needs no further processing, run the following:

```shell
sudo docker compose -f build-data.yml build --pull gtfs-data
```

Or else if you need to modify the GTFS data, add another build step:

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
export "$(grep '^COUNTRY_CODE=' < .env)"
# Set countryCode value in pelias.json file.
pelias_json="$(cat "${PELIAS_BUILD_DIR}/pelias.json")"
jq ". | .imports.whosonfirst.countryCode=\"${COUNTRY_CODE}\"" <<< "${pelias_json}" > "${PELIAS_BUILD_DIR}/pelias.json"
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

Open http://localhost:9090 and test if searching for addresses and places works.

Test if navigation works:

* For the VGN, open e.g. http://localhost:9090/reitti/Erlangen%3A%3A49.596018%2C11.001793/N%C3%BCrnberg%20Hbf%3A%3A49.446369%2C11.081806

### View healthcheck output

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
