#!/bin/bash

SCRIPT_PATH=$(dirname "$0")
SCRIPT_PATH=$(cd ${SCRIPT_PATH} && pwd)
WORKDIR="${SCRIPT_PATH}/.."

SERVER_DATA_DIR="./server-files"
HOST_DATA_DIR="./host-files"

IMAGE_TAG="local/gns3-server:latest"
CONTAINER_NAME="gns3-server"

GNS3_SRC_DIR="gns3-src"
GNS3_PORT="3080"
GNS3_HOST_IFACE="tap.gns3"
GNS3_HOST_IFACE_ADDR="192.168.201.2/24"

my_notify()
{
    notify-send "GNS3 WebUI" "$@"
}

failed()
{
    my_notify "failed"
    exit 1
}

prepare_server_dir()
{
    mkdir -p ${SERVER_DATA_DIR}/config || failed
	mkdir -p ${SERVER_DATA_DIR}/images || failed
	mkdir -p ${SERVER_DATA_DIR}/projects || failed
	mkdir -p ${SERVER_DATA_DIR}/appliances || failed
	mkdir -p ${SERVER_DATA_DIR}/docker || failed
	mkdir -p ${HOST_DATA_DIR} || failed
}

command_open()
{
    browse http://localhost:${GNS3_PORT}
}

command_start()
{
    docker container stop ${CONTAINER_NAME} 2>/dev/null

    prepare_server_dir
	docker run $@ \
		--restart unless-stopped \
        --detach \
		--name "${CONTAINER_NAME}" \
		--cap-add ALL \
		--privileged \
		--env TZ=GMT-7 \
		--net=host \
		-v "${GNS3_SRC_DIR}:/server" \
		-v "${SERVER_DATA_DIR}/config:/data/config" \
		-v "${SERVER_DATA_DIR}/images:/data/images" \
		-v "${SERVER_DATA_DIR}/projects:/data/projects" \
		-v "${SERVER_DATA_DIR}/appliances:/data/appliances" \
		-v "${SERVER_DATA_DIR}/docker:/data/docker" \
		-v "${HOST_DATA_DIR}:/data/host-files" \
			${IMAGE_TAG} || failed
    my_notify "Сервер запущен на порту ${GNS3_PORT}"
}

command_stop()
{
    docker container stop ${CONTAINER_NAME} || failed
    my_notify "Сервер остановлен"
}

command_create_iface()
{
    export SUDO_ASKPASS="./script/askpass.sh"

    sudo -A ip tuntap add dev ${GNS3_HOST_IFACE} mode tap 2>/dev/null || failed
    sudo -A ip add add ${GNS3_HOST_IFACE_ADDR} dev ${GNS3_HOST_IFACE} 2>/dev/null || failed
    sudo -A ip link set up ${GNS3_HOST_IFACE} || failed
	my_notify "Создан интерфейс: ${GNS3_HOST_IFACE} ${GNS3_HOST_IFACE_ADDR}"
}

command_console()
{
    docker exec -it -w /data/host-files ${CONTAINER_NAME} bash
}

command_build()
{
    if [ ! -d "${GNS3_SRC_DIR}" ] ; then
        git clone --depth 1 https://github.com/GNS3/gns3-server.git ${GNS3_SRC_DIR} || failed
    fi

	cp ./docker-runner.sh ${GNS3_SRC_DIR}/docker-runner.sh || failed
	chmod +x ${GNS3_SRC_DIR}/docker-runner.sh || failed
	cp ./default_gns3_server.ini ${GNS3_SRC_DIR}/default_gns3_server.ini || failed

    docker image rm ${IMAGE_TAG} -f 2>/dev/null
   	docker build -t ${IMAGE_TAG} . || failed
}

cd ${WORKDIR} || failed

CMD="$1"
shift
command_${CMD} $@
