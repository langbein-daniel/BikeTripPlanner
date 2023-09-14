ARG BUILD_NAME=build
FROM localhost/${BUILD_NAME}_osm-data AS osm

FROM localhost/${BUILD_NAME}_osmium-tool
WORKDIR /data
COPY --from=osm /data/osm.pbf      /data/input.pbf
COPY --from=osm /data/credits.json /data/credits.json

ARG MIN_LON=10.011636032586688
ARG MAX_LON=12.223993889052613
ARG MIN_LAT=48.70792025947608
ARG MAX_LAT=50.25793688217101
ARG BBOX=${MIN_LON},${MIN_LAT},${MAX_LON},${MAX_LAT}
RUN osmium extract --strategy complete_ways --bbox "${BBOX}" input.pbf -o osm.pbf \
    && rm input.pbf
