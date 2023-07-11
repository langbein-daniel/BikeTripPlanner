ARG BUILD_NAME=build
FROM ${BUILD_NAME}-gtfs-modified AS gtfs

ARG IMAGE_R_BASE=r-base
FROM ${IMAGE_R_BASE}

RUN apt-get update
RUN apt-get install -y libssl-dev
RUN apt-get install -y libudunits2-dev
RUN apt-get install -y libgdal-dev
RUN R --slave -e 'install.packages("sf")'
RUN R --slave -e 'install.packages("gtfstools")'

ADD filter.R /data/filter.R
COPY --from=gtfs /data/gtfs.zip /data/input.zip

ARG MIN_LON=10.011636032586688
ARG MAX_LON=12.223993889052613
ARG MIN_LAT=48.70792025947608
ARG MAX_LAT=50.25793688217101
RUN /data/filter.R ${MIN_LON} ${MAX_LON} ${MIN_LAT} ${MAX_LAT}