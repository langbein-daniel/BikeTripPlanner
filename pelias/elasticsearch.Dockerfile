ARG PELIAS_ELASTICSEARCH=pelias/elasticsearch:7.16.1
FROM ${PELIAS_ELASTICSEARCH}
COPY ./elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY ./data/elasticsearch /usr/share/elasticsearch/data

# https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html#cluster-health-api-desc
# curl
#   -sS: disable progress meter but still show error messages
#   -f: Fail fast with no output at all on server errors
HEALTHCHECK --interval=30s --retries=1 --start-period=15s --timeout=1s \
 CMD curl -sSf 'http://localhost:9200/_cluster/health?wait_for_status=green&timeout=1s' | grep --fixed-strings '"timed_out":false' || exit 1
