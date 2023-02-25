FROM debian:stable-slim
# https://hub.docker.com/_/debian/
# https://packages.debian.org/stable/osmium-tool
RUN apt-get update \
    && apt-get install -y osmium-tool \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data

ARG OSM_PBF_URL=https://download.geofabrik.de/europe-latest.osm.pbf
ADD ${OSM_PBF_URL} region.osm.pbf

ARG MIN_LON=10.011636032586688
ARG MAX_LON=12.223993889052613
ARG MIN_LAT=48.70792025947608
ARG MAX_LAT=50.25793688217101
ARG BBOX=${MIN_LON},${MIN_LAT},${MAX_LON},${MAX_LAT}
RUN osmium extract --strategy complete_ways --bbox "${BBOX}" region.osm.pbf -o extract.osm.pbf \
    && rm region.osm.pbf && \
    echo "${BBOX}" extract.bbox
