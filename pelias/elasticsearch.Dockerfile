ARG IMAGE_PELIAS_ELASTICSEARCH=pelias/elasticsearch:7.16.1
FROM ${IMAGE_PELIAS_ELASTICSEARCH}
COPY ./elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY ./data/elasticsearch /usr/share/elasticsearch/data

# https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html#cluster-health-api-desc
HEALTHCHECK --interval=15s --retries=20 --start-period=30s --timeout=5s \
 CMD curl -sSf 'http://localhost:9200/_cluster/health?wait_for_status=green&timeout=1s' | grep --fixed-strings '"timed_out":false' || exit 1
