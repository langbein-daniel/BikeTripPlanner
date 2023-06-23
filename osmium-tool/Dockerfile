FROM debian:stable-slim
# https://hub.docker.com/_/debian/
# https://packages.debian.org/stable/osmium-tool
RUN apt-get update \
    && apt-get install -y osmium-tool \
    && rm -rf /var/lib/apt/lists/*
