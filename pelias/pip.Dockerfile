ARG PELIAS_PIP=pelias/pip-service:master
FROM ${PELIAS_PIP}
COPY ./pelias.json /code/pelias.json
COPY ./data/whosonfirst/sqlite /data/whosonfirst/sqlite

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_REQUEST
ENV HEALTHCHECK_REQUEST=${HEALTHCHECK_REQUEST}
ARG HEALTHCHECK_RESPONSE
ENV HEALTHCHECK_RESPONSE=${HEALTHCHECK_RESPONSE}
HEALTHCHECK --interval=15s --retries=1 --start-period=45s --timeout=5s \
 CMD /bin/check-health
