ARG BUILD_NAME=build
ARG IMAGE_OPENTRIPPLANNER=docker.io/opentripplanner/opentripplanner:latest

FROM ${BUILD_NAME}-osm-excerpt AS osm
FROM ${BUILD_NAME}-gtfs-modified AS gtfs

FROM ${IMAGE_OPENTRIPPLANNER} as builder
# Current entrypoint: /docker-entrypoint.sh
# Running `sudo docker run --rm --entrypoint cat docker.io/opentripplanner/opentripplanner:latest /docker-entrypoint.sh` reveals:
#   java $JAVA_OPTS -cp @/app/jib-classpath-file @/app/jib-main-class-file /var/opentripplanner/ $@

RUN apt-get update \
    && apt-get install -y jq \
    && rm -rf /var/lib/apt/lists/*

# Copy build configuration.
COPY ./build-config.json  /var/opentripplanner/
# Remove line comments from build-config.json
RUN sed 's|^\s*//.*||' /var/opentripplanner/build-config.json > /tmp/build-config.json
# Set .osmDefaults.timeZone variable in build-config.json
ARG TIMEZONE=Europe/Berlin
RUN jq ". | .osmDefaults.timeZone=\"${TIMEZONE}\"" /tmp/build-config.json > /var/opentripplanner/build-config.json \
    && rm /tmp/build-config.json

# Copy OTP configuration.
# otp-config.json contains settings relevant during graph creation.
COPY ./otp-config.json    /var/opentripplanner/

# Build street graph.
# Results in `streetGraph.obj`.
COPY --from=osm /data/extract.osm.pbf /var/opentripplanner/extract.osm.pbf
# TODO: add DEM/GeoTIFF to pipeline
#COPY merged.tif /var/opentripplanner/elevation.tif
ARG JAVA_BUILD_OPTS
ENV JAVA_OPTS=${JAVA_BUILD_OPTS}
RUN /docker-entrypoint.sh --buildStreet \
    && rm /var/opentripplanner/extract.osm.pbf
#    && rm /var/opentripplanner/elevation.tif

# Add timetable data to graph.
# Results in `graph.obj`.
COPY --from=gtfs /data/gtfs.zip /var/opentripplanner/gtfs.zip
RUN /docker-entrypoint.sh --loadStreet --save \
    && rm /var/opentripplanner/gtfs.zip \
    && rm /var/opentripplanner/streetGraph.obj

FROM ${IMAGE_OPENTRIPPLANNER}

COPY --from=builder /var/opentripplanner/build-config.json /var/opentripplanner/build-config.json
COPY --from=builder /var/opentripplanner/otp-config.json   /var/opentripplanner/otp-config.json
COPY --from=builder /var/opentripplanner/graph.obj         /var/opentripplanner/graph.obj
COPY ./router-config.json                                  /var/opentripplanner/router-config.json

ARG JAVA_OPTS
ENV JAVA_OPTS=${JAVA_OPTS}
CMD ["--load", "--serve"]

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_AGENCY_NAME=VGN
ENV HEALTHCHECK_AGENCY_NAME=${HEALTHCHECK_AGENCY_NAME}
HEALTHCHECK --interval=15s --retries=9 --start-period=45s --timeout=5s \
 CMD /bin/check-health
