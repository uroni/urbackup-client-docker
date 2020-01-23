# Base image can be specified by --build-arg IMAGE_ARCH= ; defaults to debian:buster
ARG IMAGE_ARCH=debian:buster
FROM ${IMAGE_ARCH}

ENV DEBIAN_FRONTEND=noninteractive
ARG VERSION=2.4.10
ENV VERSION ${VERSION}
ARG ARCH=amd64
ARG QEMU_ARCH
ENV FILE UrBackup%20Client%20Linux%20${VERSION}.sh
ENV URL https://hndl.urbackup.org/Client/${VERSION}/${FILE}

ENV URBACKUP_SERVER_NAME ""
ENV URBACKUP_SERVER_PORT 55415
ENV URBACKUP_SERVER_PROXY ""
ENV URBACKUP_CLIENT_NAME ""
ENV URBACKUP_CLIENT_AUTHKEY ""


# Copy the entrypoint-script and the emulator needed for autobuild function of DockerHub
COPY entrypoint.sh qemu-${QEMU_ARCH}-static* /usr/bin/
ADD ${URL} /root/install.sh


RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y lsb-base ca-certificates &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*
	
RUN TF=sh /root/install.sh &&\
        rm -f /root/install.sh &&\
		mkdir -p /backup &&\        
        ( [ ! -e /etc/default/urbackupclient ] || sed -i 's/INTERNET_ONLY=false/INTERNET_ONLY=true/' /etc/default/urbackupclient ) &&\
        ( [ ! -e /etc/sysconfig/urbackupclient ] || sed -i 's/INTERNET_ONLY=false/INTERNET_ONLY=true/' /etc/sysconfig/urbackupclient ) &&\
        mkdir -p /backup &&\
		urbackupclientctl wait-for-backend &&\
        urbackupclientctl add -d /backup
		
# Making entrypoint-script executable
RUN chmod +x /usr/bin/entrypoint.sh

# /usr/share/urbackup will not be exported to a volume by default, but it still can be bind mounted
VOLUME [ "/backup" ]
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["run"]
