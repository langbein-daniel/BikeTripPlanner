# Execute the commands of each target in one
# shell to allow using the same shell variables
# in multiple commands.
.ONESHELL:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
# TODO:
#   When using shell variables in a recipe, don't forget to escape them with `$`.
#   To search for unescaped `$`, the following regex can be used: `[^\$]\$[^\$]`.

DOCKER_BUILD_ARGS := --progress=plain
#DOCKER_BUILD_ARGS := --progress=plain --no-cache

.PHONY: all
all: build test  ## Default target. Build and test BikeTripPlanner Docker images.

# The `build` target consists of all `build-*` targets below.
# Their ordering is important.
# Details on the individual steps are given in `README.md`.
.PHONY: build
build: build-data build-tilemaker build-otp-config build-pelias-import build-images  ## Build BikeTripPlanner Docker images.

.PHONY: build-data
build-data:
	export "$$(grep '^GTFS_MODIFICATION_PARAM=' < .env)"
	if [ ! "$${GTFS_MODIFICATION_PARAM}" = "" ]; then \
	  sudo docker compose -f build-data-vgn.yml build $(DOCKER_BUILD_ARGS) --pull gtfs-data-raw; \
	  sudo docker compose -f build-data-vgn.yml build $(DOCKER_BUILD_ARGS) gtfs-data; \
	else \
	  sudo docker compose -f build-data.yml build $(DOCKER_BUILD_ARGS) --pull gtfs-data; \
	fi
	sudo docker compose -f build-data.yml build $(DOCKER_BUILD_ARGS) --pull osm-excerpt
.PHONY: build-tilemaker
build-tilemaker:
	sudo docker compose -f build-tilemaker.yml build $(DOCKER_BUILD_ARGS) --pull tilemaker
.PHONY: build-otp-config
build-otp-config:
	export "$$(grep '^TIMEZONE=' < .env)"
	build_config_json="$$(sed 's|^\s*//.*||' opentripplanner/build-config.json)"
	jq ". | .osmDefaults.timeZone=\"$${TIMEZONE}\"" <<< "$${build_config_json}" > opentripplanner/build-config.json
.PHONY: build-pelias-import
build-pelias-import: clean-pelias-import
	export "$$(grep '^BUILD_NAME=' < .env)"
	export "$$(grep '^PELIAS_BUILD_DIR=' < .env)"
	export "$$(grep '^COUNTRY_CODE=' < .env)"
	export "$$(grep '^WOF_IDS=' < .env)"

	pelias_json="$$(cat "$${PELIAS_BUILD_DIR}/pelias.json")"
	if [ "$${COUNTRY_CODE}" = "" ]; then \
	  jq 'del(.imports.whosonfirst.countryCode)' <<< "$${pelias_json}" > "$${PELIAS_BUILD_DIR}/pelias.json"; \
	else \
	  jq ". | .imports.whosonfirst.countryCode=\"$${COUNTRY_CODE}\"" <<< "$${pelias_json}" > "$${PELIAS_BUILD_DIR}/pelias.json"; \
	fi

	pelias_json="$$(cat "$${PELIAS_BUILD_DIR}/pelias.json")"
	if [ "$${WOF_IDS}" = "" ]; then \
	  jq 'del(.imports.whosonfirst.importPlace)' <<< "$${pelias_json}" > "$${PELIAS_BUILD_DIR}/pelias.json"; \
	else \
	  jq --argjson wof_ids "$${WOF_IDS}" '. | .imports.whosonfirst.importPlace=$$wof_ids' <<< "$${pelias_json}" > "$${PELIAS_BUILD_DIR}/pelias.json"; \
	fi

	sudo install --directory -m755 -o1000 -g1000 "$${PELIAS_BUILD_DIR}/data/" "$${PELIAS_BUILD_DIR}/data/"{elasticsearch,openstreetmap,gtfs}

	sudo docker compose -f build-pelias.yml up -d --wait elasticsearch
	sudo docker compose -f build-pelias.yml run --rm schema ./bin/create_index
	sudo docker run --rm --entrypoint cat $${BUILD_NAME}-osm-excerpt /data/extract.osm.pbf > "$${PELIAS_BUILD_DIR}/data/openstreetmap/extract.osm.pbf"
	sudo docker run --rm --entrypoint cat $${BUILD_NAME}-gtfs-data   /data/gtfs.zip        > "$${PELIAS_BUILD_DIR}/data/gtfs/gtfs.zip"
	sudo docker compose -f build-pelias.yml run --rm whosonfirst   ./bin/download
	sudo docker compose -f build-pelias.yml run --rm polylines     ./docker_extract.sh
	sudo docker compose -f build-pelias.yml run --rm placeholder   ./cmd/extract.sh
	sudo docker compose -f build-pelias.yml run --rm placeholder   ./cmd/build.sh
	sudo docker compose -f build-pelias.yml run --rm interpolation ./docker_build.sh
	sudo docker compose -f build-pelias.yml run --rm whosonfirst   ./bin/start
	sudo docker compose -f build-pelias.yml run --rm openstreetmap ./bin/start
	sudo docker compose -f build-pelias.yml run --rm polylines     ./bin/start
	sudo docker compose -f build-pelias.yml build $(DOCKER_BUILD_ARGS) gtfs
	sudo docker compose -f build-pelias.yml run --rm gtfs  ./bin/start
	sudo docker compose -f build-pelias.yml down
.PHONY: build-images
build-images:
	sudo docker compose build $(DOCKER_BUILD_ARGS)

.PHONY: test
test: start stop  ## Test the built Docker images.

.PHONY: publish
publish:  ## Upload Docker images to container registry.
	./publish.sh

.PHONY: start
start: stop  ## (Re-)Start local BikeTripPlanner instance.
	sudo docker compose up -d --wait

.PHONY: stop
stop:  ## Stop local BikeTripPlanner instance.
	sudo docker compose down

.PHONY: clean
clean: clean-pelias-import  ## Clean up after `make build`.

.PHONY: clean-pelias-import
clean-pelias-import:
	sudo docker compose -f build-pelias.yml down

	export "$$(grep '^PELIAS_BUILD_DIR=' < .env)"
	sudo rm -rf "$${PELIAS_BUILD_DIR}/data"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
