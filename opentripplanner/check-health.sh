#!/usr/bin/env sh
set -u

# -sS: disable progress meter but still show error messages
# -f: Fail fast with no output at all on server errors
curl -sSf --request POST --url 'http://localhost:8080/otp/routers/default/index/graphql' --header 'Content-Type: application/json' --header 'OTPTimeout: 1000' --data '{"query":"query agencies {agencies {name}}","operationName":"agencies"}' | grep --fixed-strings "\"name\":\"${HEALTHCHECK_AGENCY_NAME}\"" || exit 1
