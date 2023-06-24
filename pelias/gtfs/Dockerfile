# source: https://github.com/pelias/transit/blob/9817c8915b164294687f2908066b6d0adb6db223/Dockerfile
# source: https://github.com/HSLdevcom/pelias-data-container/blob/7fd2b552f172763cf16d99756812ee014fc5ba5c/scripts/install-tools.sh#L31

# base image
ARG IMAGE_PELIAS_BASE=pelias/baseimage:master
FROM ${IMAGE_PELIAS_BASE}

# download apt dependencies
# note: this is done in one command in order to keep down the size of intermediate containers
RUN apt-get update && apt-get install -y git unzip python python-pip python-dev build-essential gdal-bin rlwrap procps emacs curl && rm -rf /var/lib/apt/lists/*

# change working dir
ENV WORKDIR=/code/pelias/gtfs
WORKDIR ${WORKDIR}

ARG DOCKERFILE_PELIAS_GTFS=https://github.com/HSLdevcom/pelias-gtfs
RUN git clone --single-branch ${DOCKERFILE_PELIAS_GTFS} ${WORKDIR}
RUN npm install

# add local code
COPY ./start.sh ${WORKDIR}/bin/start

# run as the pelias user
USER pelias
