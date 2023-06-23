# OpenStreetMap Polylines Extract

There are three options to get a polylines extract:

* `sudo docker compose -f build-pelias.yml run --rm polylines ./docker_extract.sh`
* Download pregenerated polyline, e.g. for country Germany. As of 2020-06, these are 10 months out of date. https://github.com/pelias/polylines#download-data
* Generate polyline from `.pbf` file: https://github.com/pelias/polylines#generating-a-custom-polylines-extract-from-a-pbf-extract

The following steps describe the third alternative, which does also work with large OSM input files:

```shell
sudo pacman -S --needed go
export PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"
```

```shell
OSM=../data/openstreetmap/extract.osm.pbf
POLYLINES=../data/polylines/extract.0sv

go version
go install github.com/missinglink/pbf@latest
pbf --help
pbf streets "${OSM}" > "${POLYLINES}"
```
