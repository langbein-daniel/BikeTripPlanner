ARG PELIAS_API=pelias/api:master
FROM ${PELIAS_API}
COPY ./pelias.json /code/pelias.json
