#!/bin/bash

DOCKER_DATA_ROOT="/data/docker"

if ! [ -f "/data/config/gns3_server.ini" ] ; then
    cp ./default_gns3_server.ini /data/config/gns3_server.ini || exit 1
fi

dockerd --data-root ${DOCKER_DATA_ROOT} &
exec python3 -m gns3server --config /data/config/gns3_server.ini -L -A
