ARG BUILD_NAME=build
ARG IMAGE_OPENTRIPPLANNER=docker.io/opentripplanner/opentripplanner:latest

FROM ${BUILD_NAME}-osm-excerpt AS osm
FROM ${BUILD_NAME}-gtfs-data AS gtfs

FROM ${IMAGE_OPENTRIPPLANNER}
# Current entrypoint: /docker-entrypoint.sh
# Running `sudo docker run --rm --entrypoint cat docker.io/opentripplanner/opentripplanner:latest /docker-entrypoint.sh` reveals:
#   java $JAVA_OPTS -cp @/app/jib-classpath-file @/app/jib-main-class-file /var/opentripplanner/ $@

COPY ./build-config.json  /var/opentripplanner/
# otp-config.json contains settings relevant during graph creation
COPY ./otp-config.json    /var/opentripplanner/

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

COPY ./router-config.json /var/opentripplanner/

ARG JAVA_OPTS
ENV JAVA_OPTS ${JAVA_OPTS}
CMD ["--load", "--serve"]

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_AGENCY_NAME=VGN
ENV HEALTHCHECK_AGENCY_NAME=${HEALTHCHECK_AGENCY_NAME}
HEALTHCHECK --interval=15s --retries=3 --start-period=45s --timeout=5s \
 CMD /bin/check-health
