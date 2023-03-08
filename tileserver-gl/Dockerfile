ARG NAME=journey-planner

# ADD GIT-URL is not yet stable Dockerfile syntax. Thus, we install and clone with git manually.
# https://docs.docker.com/engine/reference/builder/#adding-a-git-repository-add-git-ref-dir
FROM debian:stable-slim AS map-style
# https://hub.docker.com/_/debian/
RUN apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*
ARG MAP_STYLE_URL=https://github.com/langbein-daniel/cyclo-bright-gl-style.git
RUN git clone --single-branch ${MAP_STYLE_URL} /data

FROM ${NAME}-osm-excerpt AS osm

FROM openmaptiles/openmaptiles-tools:7.0 AS sprites
WORKDIR /data
COPY --from=map-style /data/icons icons
RUN mkdir /build \
    && spritezero /build/style icons \
    && spritezero --retina /build/style@2x icons

FROM ${NAME}-tilemaker AS tilemaker
RUN apt-get update \
    && apt-get install -y make bc curl unzip jq \
    && rm -rf /var/lib/apt/lists/*
RUN ln -s /tilemaker /usr/bin/tilemaker
# Now we have the commands make, bc, curl, unzip, jq and tilemaker available.

WORKDIR /data
COPY --from=map-style /data .
COPY --from=sprites /build build/sprites
COPY --from=osm /data/extract.osm.pbf build/unnamed/extract.osm.pbf
RUN mkdir -p download && touch download/europe.osm.pbf && touch build/unnamed/extract.osm.pbf

ARG MIN_LON=10.011636032586688
ARG MAX_LON=12.223993889052613
ARG MIN_LAT=48.70792025947608
ARG MAX_LAT=50.25793688217101
RUN make \
  NAME=unnamed \
  ${MIN_LON}=10.011636032586688 \
  ${MAX_LON}=12.223993889052613 \
  ${MIN_LAT}=48.70792025947608 \
  ${MAX_LAT}=50.25793688217101 \
  data-tileserver-gl \
  && rm data-tileserver-gl/.data-unnamed \
  && make clean

FROM maptiler/tileserver-gl
COPY --from=tilemaker /data/data-tileserver-gl /data
