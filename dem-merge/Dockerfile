ARG BUILD_NAME=build
FROM ${BUILD_NAME}-dem-data AS dem

# https://github.com/OSGeo/gdal/pkgs/container/gdal
#FROM ghcr.io/osgeo/gdal:alpine-small-latest
FROM ghcr.io/osgeo/gdal:alpine-normal-latest

COPY --from=dem /data/ /data/input/

RUN gdal_merge.py -o /data/dem.tif /data/input/*.tif \
    && rm -r /data/input
