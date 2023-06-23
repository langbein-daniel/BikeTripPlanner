FROM golang
RUN go install github.com/missinglink/pbf@latest
USER 1000:1000
CMD sh -c 'mkdir -p /data/polylines && pbf streets /data/openstreetmap/osm.pbf > /data/polylines/extract.0sv'
