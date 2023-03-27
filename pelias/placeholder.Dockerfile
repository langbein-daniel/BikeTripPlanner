ARG PELIAS_PLACEHOLDER=pelias/placeholder:master
FROM ${PELIAS_PLACEHOLDER}
ARG PORT=4100
ENV PORT=${PORT}
COPY ./pelias.json /code/pelias.json
COPY ./data/placeholder/store.sqlite3 /data/placeholder/store.sqlite3

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_REQUEST
ENV HEALTHCHECK_REQUEST=${HEALTHCHECK_REQUEST}
ARG HEALTHCHECK_RESPONSE
ENV HEALTHCHECK_RESPONSE=${HEALTHCHECK_RESPONSE}
HEALTHCHECK --interval=15s --retries=4 --start-period=30s --timeout=5s \
 CMD /bin/check-health
