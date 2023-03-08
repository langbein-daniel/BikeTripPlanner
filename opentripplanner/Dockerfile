ARG BUILD_NAME=journey-planner
FROM ${BUILD_NAME}-osm-excerpt AS osm
FROM ${BUILD_NAME}-gtfs-data AS gtfs

FROM docker.io/opentripplanner/opentripplanner:latest
# Current entrypoint: /docker-entrypoint.sh
# Running `sudo docker run --rm --entrypoint cat docker.io/opentripplanner/opentripplanner:latest /docker-entrypoint.sh` reveals:
#   java $JAVA_OPTS -cp @/app/jib-classpath-file @/app/jib-main-class-file /var/opentripplanner/ $@

COPY ./build-config.json /var/opentripplanner/
COPY ./otp-config.json /var/opentripplanner/

# Build street graph.
# Results in `streetGraph.obj`.
COPY --from=osm /data/extract.osm.pbf /var/opentripplanner/extract.osm.pbf
ARG JAVA_BUILD_OPTS
ENV JAVA_OPTS ${JAVA_BUILD_OPTS}
RUN /docker-entrypoint.sh --buildStreet \
    && rm /var/opentripplanner/extract.osm.pbf

# Add timetable data to graph.
# Results in `graph.obj`.
COPY --from=gtfs /data/gtfs.zip /var/opentripplanner/gtfs.zip
RUN /docker-entrypoint.sh --loadStreet --save \
    && rm /var/opentripplanner/gtfs.zip \
    && rm /var/opentripplanner/streetGraph.obj

ARG JAVA_OPTS
ENV JAVA_OPTS ${JAVA_OPTS}
CMD ["--load", "--serve"]
