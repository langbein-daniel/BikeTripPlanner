#!/usr/bin/env bash
set -e
set -u

function main(){
  # Prints the Docker image size
  # of all services described in
  # docker-compose.yml.
  #
  # Note: One has to build the images
  # first before running this function.

  local services=()
  while IFS= read -r service; do
    services+=("${service}")
  done < <(docker compose config --services)

  # Set shell variables from `.env`.
  NAME=''
  export "$(grep '^NAME=' < .env)"

  for service in "${services[@]}"; do
    local image="${NAME}-${service}"
    local size
    size="$(sudo docker inspect -f "{{ .Size }}" "${image}" | numfmt --to=si)"

    printf '%s\n' "${service}: ${size}"
  done
}

main "$@"
