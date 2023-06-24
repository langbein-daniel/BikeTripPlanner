ARG IMAGE_DEBIAN=debian:stable-slim
FROM ${IMAGE_DEBIAN}
# https://hub.docker.com/_/debian/
# https://packages.debian.org/stable/osmium-tool
RUN apt-get update \
    && apt-get install -y osmium-tool \
    && rm -rf /var/lib/apt/lists/*
