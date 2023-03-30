#!/usr/bin/env sh
set -u

# `curl` options
#   -sS: disable progress meter but still show error messages
#   -f: Fail fast with no output at all on server errors

response="$(curl -sSf "http://${HEALTHCHECK_REQUEST}")" || exit 1
printf '%s' "${response}" | grep --fixed-strings "${HEALTHCHECK_RESPONSE}" || {
  printf '%s\n%s\n' "Unexpected response:" "${response}"
  exit 1
}
