# Base image can be specified by --build-arg IMAGE_ARCH= ; defaults to debian:buster
ARG IMAGE_ARCH=debian:buster
FROM ${IMAGE_ARCH}

ENV DEBIAN_FRONTEND=noninteractive
ARG VERSION=2.5.24
ENV VERSION ${VERSION}
ARG ARCH=amd64
ARG QEMU_ARCH
ENV FILE UrBackup%20Client%20Linux%20${VERSION}.sh
ENV URL https://hndl.urbackup.org/Client/${VERSION}/${FILE}

ENV URBACKUP_SERVER_PORT 55415
ENV URBACKUP_BACKUP_VOLUMES /backup

# Copy the entrypoint-script and the emulator needed for autobuild function of DockerHub
COPY entrypoint.sh qemu-${QEMU_ARCH}-static* /usr/bin/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y lsb-base ca-certificates mariadb-client-10.3 &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD ${URL} /root/install.sh
	
RUN sh /root/install.sh &&\
        rm -f /root/install.sh &&\
		mkdir -p /backup &&\        
        ( [ ! -e /etc/default/urbackupclient ] || sed -i 's/INTERNET_ONLY=false/INTERNET_ONLY=true/' /etc/default/urbackupclient ) &&\
        ( [ ! -e /etc/sysconfig/urbackupclient ] || sed -i 's/INTERNET_ONLY=false/INTERNET_ONLY=true/' /etc/sysconfig/urbackupclient ) &&\
        mkdir -p /backup
		
# Making entrypoint-script executable
RUN chmod +x /usr/bin/entrypoint.sh

# Only files in /backup will be backed up per default
VOLUME [ "/backup" ]
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["--internet-only"]
