ARG PELIAS_PLACEHOLDER=pelias/placeholder:master
FROM ${PELIAS_PLACEHOLDER}
COPY ./pelias.json /code/pelias.json
COPY ./data/placeholder/store.sqlite3 /data/placeholder/store.sqlite3

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_REQUEST
ENV HEALTHCHECK_REQUEST=${HEALTHCHECK_REQUEST}
ARG HEALTHCHECK_RESPONSE
ENV HEALTHCHECK_RESPONSE=${HEALTHCHECK_RESPONSE}
HEALTHCHECK --interval=30s --retries=1 --start-period=15s --timeout=1s \
 CMD /bin/check-health
