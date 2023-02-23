# Journey-planner

Get your journey-planner instance up and running with Docker Compose.

## OSM excerpt

```shell
sudo docker compose --profile osm-excerpt build
```

## Background map

Clone your cyclo-bright-gl-style repository to [./tile-data/style](tile-data/style)

```shell
git clone https://github.com/langbein-daniel/cyclo-bright-gl-style tile-data/style
```

Then do two build steps

```shell
sudo docker compose --profile tilemaker build
sudo docker compose --profile tile-data build
```

## Startup

```shell
sudo docker compose up
```
