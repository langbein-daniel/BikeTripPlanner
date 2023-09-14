ARG IMAGE_ALPINE=alpine
FROM ${IMAGE_ALPINE}

WORKDIR /data

ARG GTFS_URL=https://www.vgn.de/opendata/GTFS.zip
# TODO:
#  "ADD $GTFS_URL" does not work with vgn.de when using podman.
#  Probably because the website is using very old TLS.
#  The following is a workaround.
#ADD ${GTFS_URL} gtfs.zip
#
RUN apk add curl
# -L: Follow 301 redirect
# --sslv3 and --tlsv1.2 give exit code 35 when run outside of podman, thus we have to use --tlsv1.1
RUN curl --tlsv1.1 -L -o gtfs.zip "${GTFS_URL}"

ARG GTFS_CREDITS=[]
RUN printf "%s" "${GTFS_CREDITS}" > credits.json
RUN cat credits.json
