ARG PELIAS_ELASTICSEARCH=pelias/elasticsearch:7.16.1
FROM ${PELIAS_ELASTICSEARCH}
COPY ./elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY ./data/elasticsearch /usr/share/elasticsearch/data
