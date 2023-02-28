ARG PELIAS_INTERPOLATION=pelias/interpolation:master
FROM ${PELIAS_INTERPOLATION}
COPY ./pelias.json /code/pelias.json
COPY ./data/interpolation/address.db /data/interpolation/address.db
COPY ./data/interpolation/street.db  /data/interpolation/street.db
