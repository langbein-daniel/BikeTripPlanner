ARG IMAGE_PELIAS_INTERPOLATION=pelias/interpolation:master
FROM ${IMAGE_PELIAS_INTERPOLATION}
ARG PORT=4300
ENV PORT=${PORT}
COPY ./pelias.json /code/pelias.json
COPY ./data/interpolation/address.db /data/interpolation/address.db
COPY ./data/interpolation/street.db  /data/interpolation/street.db

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_REQUEST
ENV HEALTHCHECK_REQUEST=${HEALTHCHECK_REQUEST}
ARG HEALTHCHECK_RESPONSE
ENV HEALTHCHECK_RESPONSE=${HEALTHCHECK_RESPONSE}
HEALTHCHECK --interval=15s --retries=12 --start-period=30s --timeout=5s \
 CMD /bin/check-health
