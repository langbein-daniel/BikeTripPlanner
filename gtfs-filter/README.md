# GTFS Filtering

There are multiple libraries available to do this.

* Below this question, multiple options are named: https://gis.stackexchange.com/questions/219382/how-to-extract-a-small-area-from-a-big-gtfs-feed

## gtfs-filter

* https://github.com/twalcari/gtfs-filter#usage
* Written in Java
* Last updated 2011

## gtfstools

* https://github.com/ipeaGIT/gtfstools#usage
* Written in R
* Has a function to intersect a GTFS feed with a geometric (`simple features`) object: `filter_by_sf(gtfs, geom, spatial_operation = sf::st_intersects, keep = TRUE)`
  * https://ipeagit.github.io/gtfstools/reference/filter_by_sf.html
* See [filter.R](filter.R) for intersection with a bounding box

Local development on Arch Linux:

```shell
sudo pacman -S --needed r tk gcc-fortran
R
```
```R
install.packages("sf")
#=> installing to ~/R/x86_64-pc-linux-gnu-library/...
install.packages("gtfstools")
```

## onebusaway-gtfs-transformer-cli

* https://github.com/OneBusAway/onebusaway-gtfs-modules/tree/master/onebusaway-gtfs-transformer-cli
* Written in Java
* http://developer.onebusaway.org/modules/onebusaway-gtfs-modules/current-SNAPSHOT/onebusaway-gtfs-transformer-cli.html#How_to_Reduce_your_GTFS

Can be used to keep only certain GTFS entities (and all other entities required directly or indirectly by those entities).

Example:

`modifications.txt`:

```
{"op":"retain", "match":{"file":"routes.txt", "route_short_name":"B15"}}
{"op":"retain", "match":{"file":"routes.txt", "route_short_name":"B62"}}
{"op":"retain", "match":{"file":"routes.txt", "route_short_name":"B63"}}
{"op":"retain", "match":{"file":"routes.txt", "route_short_name":"BX19"}}
{"op":"retain", "match":{"file":"routes.txt", "route_short_name":"Q54"}}
{"op":"retain", "match":{"file":"routes.txt", "route_short_name":"S53"}}
```

Apply `modifications.txt` to a GTFS feed:

```shell
java -jar onebusaway-gtfs-transformer-cli.jar --transform=modifications.txt source-gtfs.zip target-gtfs.zip
```

This _could_ be used to geographically filter a GTFS feed. First, one would need to identify all routes (and their short names), that intersect with a bounding box. Then save them in as `modifications.txt` in the format visible above. Finally, execute `onebusaway-gtfs-transformer-cli.jar`.

## gtfs_kit

TODO: Evaluate this project.

* https://github.com/mrcagney/gtfs_kit
* Written in Python
* Currently, in Alpha: This project's development status is Alpha. I use GTFS Kit for work and change it breakingly to suit my needs.
* https://mrcagney.github.io/gtfs_kit_docs/index.html#gtfs_kit.miscellany.restrict_to_area
  * Build a new feed by restricting this one to only the trips that have at least one stop intersecting the given GeoDataFrame of polygons, then restricting stops, routes, stop times, etc. to those associated with that subset of trips. Return the resulting feed.

## gtfs_extractor

* Written in Python
* Last updated 2017
* https://github.com/gberaudo/gtfs_extractor#extract-data-of-interest
  * extract by bounding box
