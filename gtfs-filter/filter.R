#!/usr/bin/env Rscript

#
# Parameters
#

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 4) {
  stop("Exactly 4 arguments must be given: min_lon, max_lon, min_lat, max_lat", call.=FALSE)
}

MIN_LON <- as.double(args[1])
MAX_LON <- as.double(args[2])
MIN_LAT <- as.double(args[3])
MAX_LAT <- as.double(args[4])
# print(MIN_LON)
# print(MAX_LON)
# print(MIN_LAT)
# print(MAX_LAT)

IN <- "/data/input.zip"
OUT <- "/data/gtfs.zip"

#
# Load libraries
#

library(sf)
library(gtfstools)

#
# Create bounding box
#

# Create a closed polygon. The first and last points are identical.
points <- rbind(c(MIN_LON, MIN_LAT), c(MAX_LON, MIN_LAT), c(MAX_LON, MAX_LAT), c(MIN_LON, MAX_LAT), c(MIN_LON, MIN_LAT))
polygon <-st_polygon(list(points))
# print(polygon)

# Create a spatial object from the polygon
polygon_sfc <- st_sfc(polygon, crs = 4326)
print(polygon_sfc)

#
# Read, filter and save GTFS
#

gtfs_data <- read_gtfs(IN)
filtered_data <- filter_by_sf(gtfs_data, polygon_sfc)
write_gtfs(filtered_data, OUT)

print("Finished filtering GTFS data set.", quote=FALSE)
