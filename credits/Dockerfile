ARG BUILD_NAME=build

FROM ${BUILD_NAME}-osm-filtered AS osm
FROM ${BUILD_NAME}-gtfs-filtered AS gtfs
FROM ${BUILD_NAME}-dem-merged AS dem

FROM alpine
RUN apk add jq

COPY --from=osm  /data/credits.json /data/input/1.json
COPY --from=gtfs /data/credits.json /data/input/2.json
COPY --from=dem  /data/credits.json /data/input/3.json
RUN cat data/input/*.json | jq -s 'add' > /data/credits.json \
    && rm -r /data/input
