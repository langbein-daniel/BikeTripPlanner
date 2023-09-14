ARG BUILD_NAME=build

FROM localhost/${BUILD_NAME}_osm-filtered AS osm
FROM localhost/${BUILD_NAME}_gtfs-filtered AS gtfs
FROM localhost/${BUILD_NAME}_dem-merged AS dem

FROM alpine
RUN apk add jq

COPY --from=osm  /data/credits.json /data/input/1.json
COPY --from=gtfs /data/credits.json /data/input/2.json
COPY --from=dem  /data/credits.json /data/input/3.json
RUN cat data/input/*.json | jq -s 'add' > /data/credits.json \
    && rm -r /data/input
