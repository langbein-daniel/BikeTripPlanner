ARG PELIAS_INTERPOLATION=pelias/interpolation:master
FROM ${PELIAS_INTERPOLATION}
COPY ./pelias.json /code/pelias.json
COPY ./data/interpolation/address.db /data/interpolation/address.db
COPY ./data/interpolation/street.db  /data/interpolation/street.db

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_REQUEST
ENV HEALTHCHECK_REQUEST=${HEALTHCHECK_REQUEST}
ARG HEALTHCHECK_RESPONSE
ENV HEALTHCHECK_RESPONSE=${HEALTHCHECK_RESPONSE}
HEALTHCHECK --interval=30s --retries=1 --start-period=15s --timeout=1s \
 CMD /bin/check-health
