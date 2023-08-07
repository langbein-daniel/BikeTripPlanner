ARG BUILD_NAME=build
FROM ${BUILD_NAME}-osm-excerpt AS osm

FROM ${BUILD_NAME}-osmium-tool
WORKDIR /data
COPY --from=osm /data/osm.pbf      /data/input.pbf
COPY --from=osm /data/credits.json /data/credits.json

# Filter OSM data to reduce OTP memory usage.
# https://docs.opentripplanner.org/en/dev-2.x/Preparing-OSM/#filtering-osm-data
#
# Object types are specified as ‘n’ (for nodes), ‘w’ (for ways), ‘r’ (for relations), and ‘a’ (for areas - closed ways with 4 or more nodes and relations with type=multipolygon or type=boundary tag).
# https://docs.osmcode.org/osmium/latest/osmium-tags-filter.html
#
# `bicycle_parking` can be a way/area: https://www.openstreetmap.org/way/200183492
# `bicycle_parking` can be a relation: https://www.openstreetmap.org/relation/15765754
# `park_ride` can be a node: https://www.openstreetmap.org/node/576873268
# `park_ride` can be a way/area: https://www.openstreetmap.org/way/28452910
# `public_transport=platform` can be a node: https://www.openstreetmap.org/node/3872531357
# `public_transport=platform` can be a relation: https://www.openstreetmap.org/relation/6719764
# `railway=platform` can be a relation: https://www.openstreetmap.org/relation/6719764
# `railway=platform` can be a way/area: https://www.openstreetmap.org/way/369528697
# `highway` can be a node: https://www.openstreetmap.org/node/31003341
ARG OTP_OSM_TAGS='nwar/amenity=bicycle_parking nwar/highway nwar/public_transport=platform nwar/railway=platform nwar/park_ride=yes nwar/type=restriction nwar/type=route'
RUN osmium tags-filter input.pbf ${OTP_OSM_TAGS} -o osm.pbf -f pbf,add_metadata=false
