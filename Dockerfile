FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:gns3/ppa
RUN apt-get update && apt-get install --no-install-recommends -y \
    locales \
    wget \
    python3-pip python3-dev \ 
    qemu-system-x86 qemu-kvm qemu-utils \
    libvirt-daemon-system libvirt-clients \
    x11vnc \
    busybox-static \
    dynamips vpcs ubridge \
    make
RUN locale-gen en_US.UTF-8

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
RUN apt-get install --no-install-recommends -y ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && \
    apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

RUN mkdir -p /data/host-files
RUN mkdir -p /data/config

ADD ./gns3-src /server
WORKDIR /server

COPY ./default_gns3_server.ini ./default_gns3_server.ini
COPY ./docker-runner.sh ./docker-runner.sh
RUN chmod +x ./docker-runner.sh

RUN pip3 install --no-cache-dir -r /server/requirements.txt

EXPOSE 3080

CMD ./docker-runner.sh
