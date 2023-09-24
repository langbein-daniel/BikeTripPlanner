#!/usr/bin/env bash
set -e
set -u

function main(){
  # Tags and publishes the images
  # of all services described in
  # docker-compose.yml to Docker Hub.
  #
  # Note: One has to build the docker
  # images first and log into ones Docker
  # Hub account:
  #   sudo docker login --username <REPOSITORY-USERNAME>

  # Print help if first argument is -h or --help.
  if [ $# -gt 0 ]; then
    if [ "${1}" = '-h' ] || [ "${1}" = '--help' ]; then
      usage
      exit
    fi
  fi

  local services=()
  if [ $# -eq 0 ]; then
    # No arguments given, use all services specified inside docker-compose.yml file.
    while IFS= read -r service; do
      services+=("${service}")
    done < <(docker compose config --services)
  else
    # Use only the specified services.
    services+=("$@")
  fi

  # Set shell variables from `.env`.
  NAME=''
  DOCKER_REGISTRY_URL=''
  DOCKER_IMAGE_TAG=''
  export "$(grep '^NAME=' < .env)"
  export "$(grep '^DOCKER_REGISTRY_URL=' < .env)"
  export "$(grep '^DOCKER_IMAGE_TAG=' < .env)"

  # Save current date as yyyymmddTHHMMSS in $date
  printf -v date '%(%Y%m%dT%H%M%S)T' -1

  for service in "${services[@]}"; do
    local target_images=(
      "${DOCKER_REGISTRY_URL}${service}:${DOCKER_IMAGE_TAG}"
      "${DOCKER_REGISTRY_URL}${service}:${DOCKER_IMAGE_TAG}-${date}"
    )
    for target_image in "${target_images[@]}"; do
      local_image="${NAME}-${service}"
      echo "Tagging and pushing local docker image ${local_image} to ${target_image}"
      sudo docker tag "${local_image}" "${target_image}"
      sudo docker push "${target_image}"
    done
  done
}

function usage(){
  printf '%s\n\t%s\n' './publish.sh [SERVICE ...]' 'If no service is specified, then all services specified inside docker-compose.yml are published'
}

main "$@"
