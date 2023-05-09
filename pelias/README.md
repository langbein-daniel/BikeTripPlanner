# Pelias

The Pelias data import pipeline is based on the Pelias [example for Germany](https://github.com/pelias/docker/tree/master/projects/germany).

We have added a data importer developed by HSL that imports two layers, stops and stations, in [gtfs](gtfs).

The main configuration is done with [pelias.json](pelias.json).

## Who's On First

To import the Who's On First data covering a geographical area, one has two configuration possibilities.

Ideally, both of them are combined to drastically reduce the amount of downloaded data.

### Country code

The first one is to specify the two-digit country code of the surrounding country, e.g. Germany:

```json
{
  "imports": {
    "whosonfirst": {
      "countryCode": "DE"
    }
  }
}
```

Pelias will then download the Who's On First database for the specified country. This is approx. 1.2 GB for Germany.

However, this is not possible if the area intersects multiple countries as one can only specify one country code.

See also:
- https://www.whosonfirst.org/docs/placetypes/#iso-country-codes
- https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
- https://github.com/whosonfirst-data/whosonfirst-data#repositories

### Identifiers

The second possibility is to specify several small areas that together cover the desired area. These areas are specified by means of Who's On First IDs.

If no country code is given additionally, then Pelias will download the Who's On First database of the whole planet (approx. 51 GB) as it does not know which data set includes the IDs.

On [https://spelunker.whosonfirst.org](https://spelunker.whosonfirst.org) one can search for countries and other geographical areas, view their boundary on a map and get their ID.

To use the Who's On First data of Germany, specify the ID of Germany: `85633111`.

```json
{
  "imports": {
    "whosonfirst": {
      "importPlace": [
        "85633111"
      ]
    }
  }
}
```

To use the data of two countries, e.g. Germany and Austria, specify their IDs:

```json
{
  "imports": {
    "whosonfirst": {
      "importPlace": [
        "85633111",
        "85632785"
      ]
    }
  }
}
```

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
