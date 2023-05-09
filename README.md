# BikeTripPlanner

Get your journey-planner instance up and running with Docker Compose.

A demo instance covering the area of the German transport association
VGN is available at [https://biketripplanner.de/](https://biketripplanner.de/).

![nuremberg-bike-and-ride.png](screenshot-nuremberg-bike-and-ride.png)

## Configuration

Go through [.env](.env) and adjust the values as desired.

Important parts are:
- Bounding box describing a rectangular geographical area.
- Link to OpenStreetMap region covering the bounding box.
- Link to GTFS feed providing transit data.
- Requests to the individual services that are used for Docker container healthchecks. If the OpenStreetMap or GTFS data sources are changed, these need to be adjusted as well.

In addition to the default configuration for the area of the VGN transport association, there is a `.env` file for [Finland](examples/finnland/.env). Just overwrite [.env](.env) with it to give it a try.

For advanced configuration, see:
- [opentripplanner/README.md](opentripplanner/README.md)
- [pelias/README.md](pelias/README.md)

## Build data images

Prerequisites: Install Docker Compose, `jq`, `sudo` and optionally `make`.

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
# Adjust configuration. TODO: Move this into OTP Dockerfile and make this data pipeline step just one `docker compose build` command.
# Set shell variables from `.env`.
export "$(grep '^TIMEZONE=' < .env)"
# Change `timeZone` in build-config.json file.
# Store build-config.json without line comments in build_config_json variable.
build_config_json="$(sed 's|^\s*//.*||' opentripplanner/build-config.json)"
jq ". | .osmDefaults.timeZone=\"${TIMEZONE}\"" <<< "${build_config_json}" > opentripplanner/build-config.json

# Build final OpenTripPlanner container.
# Don't `--pull` as we are using the previously built `osm-excerpt`.
sudo docker compose build opentripplanner
```

### Geocoder (Pelias)

```shell
# Set shell variables from `.env`.
export "$(grep '^BUILD_NAME=' < .env)"
export "$(grep '^PELIAS_BUILD_DIR=' < .env)"
export "$(grep '^COUNTRY_CODE=' < .env)"
export "$(grep '^WOF_IDS=' < .env)"
# Change `countryCode` in pelias.json file.
pelias_json="$(cat "${PELIAS_BUILD_DIR}/pelias.json")"
if [ "${COUNTRY_CODE}" = "" ]; then
  # Delete `countryCode`
  jq 'del(.imports.whosonfirst.countryCode)' <<< "${pelias_json}" > "${PELIAS_BUILD_DIR}/pelias.json"
else
  # Set `countryCode`
  jq ". | .imports.whosonfirst.countryCode=\"${COUNTRY_CODE}\"" <<< "${pelias_json}" > "${PELIAS_BUILD_DIR}/pelias.json"
fi
# Change `importPlace` in pelias.json file.
pelias_json="$(cat "${PELIAS_BUILD_DIR}/pelias.json")"
if [ "${WOF_IDS}" = "" ]; then
  # Delete `importPlace`
  jq 'del(.imports.whosonfirst.importPlace)' <<< "${pelias_json}" > "${PELIAS_BUILD_DIR}/pelias.json"
else
  # Set `importPlace`
  jq --argjson wof_ids "${WOF_IDS}" '. | .imports.whosonfirst.importPlace=$wof_ids' <<< "${pelias_json}" > "${PELIAS_BUILD_DIR}/pelias.json"
fi
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

### Web UI (Digitransit-UI)

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

Tag and push the locally built images to a docker container registry:

```shell
./publish.sh
```

### Run with Docker Compose

In [deployment](deployment), there are two Docker Compose examples.

#### Nginx reverse proxy with Let's Encrypt certificates

This example includes an nginx server that receives HTTPS requests from the Internet and proxies them to the corresponding services via HTTP. Certificate creation and renewal is automated using Let's Encrypt.

```
                                        Docker Compose
                               ┌──────────────────────────────┐
                               │                              │
                               │            ┌─►Tileserver GL  │
┌─────────┐                    │            │                 │
│         │HTTPS          HTTPS│        HTTP├─►OpenTripPlanner│
│ Client◄─┼─────►Internet◄─────┼─►nginx◄────┤                 │
│         │                    │            ├─►Pelias API     │
└─────────┘                    │            │                 │
                               │            └─►Digitransit-UI │
                               │                              │
                               └──────────────────────────────┘
```

Create one domain for the UI and three subdomains for the background map, geocoder and routing services. All four domains have to point to the server intended for running BikeTripPlanner. Also, make sure that the ports 80 and 443 are opened and reachable over the Internet.

Set the domain values in [deployment/.env](deployment/.env) accordingly.

Then start your BikeTripPlanner instance with:

```shell
cd deployment
sudo docker compose -f btp-and-proxy.yml up -d --wait
```

#### Load distribution

As the Pelias and OpenTripPlanner services are quite RAM and CPU intensive, one might want to run some of the Docker containers on different servers to spread the load or even introduce load balancing of e.g. routing requests over multiple OpenTripPlanner instances.

This second example gives an overview how the large Docker Compose project can be split up into smaller parts, each of which run on a different server.

Separating the background map, routing, geocoding and UI services is as easy as copying the corresponding services from the [deployment/btp-and-proxy.yml](deployment/btp-and-proxy.yml) Docker Compose file into separate files and removing the `depends_on` statements of services that are no longer part of the same Docker Compose file. It is thereafter the users responsibility to start the Docker Compose projects in the correct order (e.g. starting the UI project last).

As we want to keep this example simple, we leave it up to the user which of the services named above they want to separate and keep them all in one Docker Compose project. But we lay the foundation to fine granular load distribution and load balancing by introducing a dedicated reverse proxy server which removes the CPU load of encrypting and decrypting HTTPS connections away from the BikeTripPlanner services.

```
                                                       Docker Compose
                                              ┌──────────────────────────────┐
                                              │                              │
                              Docker Compose  │            ┌─►Tileserver GL  │
┌─────────┐                    ┌─────────┐    │            │                 │
│         │HTTPS          HTTPS│         │HTTP│        HTTP├─►OpenTripPlanner│
│ Client◄─┼─────►Internet◄─────┼─►nginx◄─┼────┼─►nginx◄────┤                 │
│         │                    │         │    │            ├─►Pelias API     │
└─────────┘                    └─────────┘    │            │                 │
                                              │            └─►Digitransit-UI │
                                              │                              │
                                              └──────────────────────────────┘
```

Create one domain for the UI and three subdomains for the background map, geocoder and routing services. All four domains have to point to the server intended for running the reverse proxy. Also, make sure that the ports 80 and 443 are open and reachable over the Internet on that server.

Set the domain values in [deployment/.env](deployment/.env) accordingly.

Set the IP of the BikeTripPlanner server in [deployment/.env](deployment/.env) for all four BikeTripPlanner services. (If you run e.g. OpenTripPlanner separately from the other BikeTripPlanner services, then set `IP_OPENTRIPPLANNER` to a different IP.)

On your reverse proxy server:

```shell
cd deployment
sudo docker compose -f proxy-only.yml up -d --wait
```

On your BikeTripPlanner server:

```shell
cd deployment
sudo docker compose -f btp-only.yml up -d --wait
```
