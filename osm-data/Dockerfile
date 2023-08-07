ARG IMAGE_ALPINE=alpine
FROM ${IMAGE_ALPINE}

WORKDIR /data

ARG OSM_PBF_URL=https://download.geofabrik.de/europe/germany-latest.osm.pbf
ADD ${OSM_PBF_URL} osm.pbf

RUN printf '%s' '[{"license":"Open Data Commons Open Database License","text":"Map data from OpenStreetMap. This includes, among others, roads, bicycle and car parking, addresses, public transit stops and public transit routes. https://osm.org/copyright"}]' > credits.json
