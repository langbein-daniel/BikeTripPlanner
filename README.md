# BikeTripPlanner

Get your journey-planner instance up and running with Docker Compose.

## OSM excerpt

```shell
sudo docker compose --profile osm-excerpt build
```

## Background map

```shell
sudo docker compose --profile tilemaker build
sudo docker compose --profile tile-data build
```

## Startup

```shell
sudo docker compose up
```
