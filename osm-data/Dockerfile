ARG IMAGE_ALPINE=alpine
FROM ${IMAGE_ALPINE}

WORKDIR /data

ARG OSM_PBF_URL=https://download.geofabrik.de/europe/germany-latest.osm.pbf
ADD ${OSM_PBF_URL} osm.pbf
