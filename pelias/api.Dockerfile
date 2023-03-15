ARG PELIAS_API=pelias/api:master
FROM ${PELIAS_API}
COPY ./pelias.json /code/pelias.json

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_REQUEST
ENV HEALTHCHECK_REQUEST=${HEALTHCHECK_REQUEST}
ARG HEALTHCHECK_RESPONSE
ENV HEALTHCHECK_RESPONSE=${HEALTHCHECK_RESPONSE}
HEALTHCHECK --interval=15s --retries=1 --start-period=30s --timeout=5s \
 CMD /bin/check-health
