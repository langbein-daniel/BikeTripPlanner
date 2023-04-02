# OpenTripPlanner configuration

* https://docs.opentripplanner.org/en/dev-2.x/Configuration/#three-scopes-of-configuration

## [build-config.json](build-config.json)

> Options and parameters that are taken into account during the graph building process will be "baked into" the graph, and cannot be changed later in a running server. These are specified in `build-config.json`.

## [router-config.json](router-config.json)

> Other details of OTP operation can be modified without rebuilding the graph. These run-time configuration options are found in `router-config.json`.

## [otp-config.json](otp-config.json)

> Finally, `otp-config.json` contains simple switches that enable or disable system-wide features.

## OTP Graph Report

Generate an HTML report of Graph errors/warnings.

1) Enable report creation in `build-config.json`
2) `sudo docker compose build opentripplanner`
3) `sudo docker compose up -d opentripplanner`
4) `sudo docker compose cp opentripplanner:/var/opentripplanner/report report`
5) Open `report/index.html`
