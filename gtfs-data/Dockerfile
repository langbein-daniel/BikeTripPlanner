ARG IMAGE_ALPINE=alpine
FROM ${IMAGE_ALPINE}

WORKDIR /data

ARG GTFS_URL=https://www.vgn.de/opendata/GTFS.zip
ADD ${GTFS_URL} gtfs.zip

ARG GTFS_CREDITS=[]
RUN printf "%s" "${GTFS_CREDITS}" > credits.json
RUN cat credits.json