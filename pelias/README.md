# Pelias

The Pelias data import pipeline is based on the Pelias [example for Germany](https://github.com/pelias/docker/tree/master/projects/germany).

We have added an additional data importer developed by HSL that adds two layers, stops and stations, in [gtfs](gtfs).

The main configuration is done with [pelias.json](pelias.json).

## Sources

After the data import, one can query data of specific sources.

To get a list of all available sources, one can e.g. use this invalid request http://localhost:4000/v1/search?sources= and get a json response containing the following:

```json
{
  "geocoding": {
    "errors": [
      "sources parameter cannot be an empty string. Valid options: osm,oa,gn,wof,openstreetmap,whosonfirst,gtfs1"
    ]
  }
}
```

## Layers

Similarly to the steps described in _sources_, one can get a list of available layers with e.g. this request: http://localhost:4000/v1/search?layers=

```json
{
  "geocoding": {
    "errors": [
      "layers parameter cannot be an empty string. Valid options: coarse,address,venue,street,neighbourhood,locality,localadmin,county,macrocounty,region,borough,country,stop,station"
    ]
  }
}
```
