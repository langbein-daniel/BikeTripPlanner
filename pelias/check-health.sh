#!/usr/bin/env sh
set -u

# curl
#   -sS: disable progress meter but still show error messages
#   -f: Fail fast with no output at all on server errors
curl -sSf "http://${HEALTHCHECK_REQUEST}" | grep --fixed-strings "${HEALTHCHECK_RESPONSE}" || exit 1

# For debugging purposes, don't filter/check the output:
#curl -sSf "http://${HEALTHCHECK_REQUEST}" || exit 1
