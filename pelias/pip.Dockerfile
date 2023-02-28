ARG PELIAS_PIP=pelias/pip-service:master
FROM ${PELIAS_PIP}
COPY ./pelias.json /code/pelias.json
COPY ./data/whosonfirst/sqlite /data/whosonfirst/sqlite
