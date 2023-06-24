ARG BUILD_NAME=build
FROM ${BUILD_NAME}-osm-excerpt AS osm

FROM ${BUILD_NAME}-osmium-tool
WORKDIR /data
COPY --from=osm /data/osm.pbf /data/input.pbf

# Filter OSM data to reduce OTP memory usage.
# https://docs.opentripplanner.org/en/dev-2.x/Preparing-OSM/#filtering-osm-data
ARG OTP_OSM_TAGS='n/amenity=bicycle_parking w/highway w/public_transport=platform w/railway=platform w/park_ride=yes r/type=restriction r/type=route'
RUN osmium tags-filter input.pbf ${OTP_OSM_TAGS} -o osm.pbf -f pbf,add_metadata=false
