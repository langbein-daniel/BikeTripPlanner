ARG BUILD_NAME=build
FROM localhost/${BUILD_NAME}_dem-data AS dem

# https://github.com/OSGeo/gdal/pkgs/container/gdal
#FROM ghcr.io/osgeo/gdal:alpine-small-latest
FROM ghcr.io/osgeo/gdal:alpine-normal-latest

COPY --from=dem /data/ /data/input/

RUN gdal_merge.py -o /data/dem.tif /data/input/*.tif \
    && mv /data/input/credits.json /data/credits.json \
    && rm -r /data/input
