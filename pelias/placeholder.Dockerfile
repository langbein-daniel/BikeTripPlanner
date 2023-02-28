ARG PELIAS_PLACEHOLDER=pelias/placeholder:master
FROM ${PELIAS_PLACEHOLDER}
COPY ./pelias.json /code/pelias.json
COPY ./data/placeholder/store.sqlite3 /data/placeholder/store.sqlite3
