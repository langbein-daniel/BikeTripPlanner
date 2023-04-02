ARG IMAGE_PELIAS_LIBPOSTAL=pelias/libpostal-service
FROM ${IMAGE_PELIAS_LIBPOSTAL}
ARG PORT=4400
ENV PORT=${PORT}

COPY ./check-health.sh /bin/check-health
ARG HEALTHCHECK_REQUEST
ENV HEALTHCHECK_REQUEST=${HEALTHCHECK_REQUEST}
ARG HEALTHCHECK_RESPONSE
ENV HEALTHCHECK_RESPONSE=${HEALTHCHECK_RESPONSE}
HEALTHCHECK --interval=15s --retries=8 --start-period=30s --timeout=5s \
 CMD /bin/check-health
