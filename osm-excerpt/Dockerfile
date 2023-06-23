ARG BUILD_NAME=journey-planner
FROM ${BUILD_NAME}-osm-data AS osm

FROM ${BUILD_NAME}-osmium-tool
WORKDIR /data
COPY --from=osm /data/osm.pbf /data/input.pbf

ARG MIN_LON=10.011636032586688
ARG MAX_LON=12.223993889052613
ARG MIN_LAT=48.70792025947608
ARG MAX_LAT=50.25793688217101
ARG BBOX=${MIN_LON},${MIN_LAT},${MAX_LON},${MAX_LAT}
RUN osmium extract --strategy complete_ways --bbox "${BBOX}" input.pbf -o osm.pbf \
    && rm input.pbf
