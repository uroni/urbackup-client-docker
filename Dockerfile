# Base image can be specified by --build-arg IMAGE_ARCH=
ARG IMAGE_ARCH=debian:bookworm
FROM ${IMAGE_ARCH}

# Version will be passed by GitHub Actions
ARG VERSION
ARG ARCH=amd64

# Validate that VERSION was provided
RUN test -n "$VERSION" || (echo "ERROR: VERSION build arg is required" && exit 1)

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    VERSION=${VERSION} \
    URBACKUP_SERVER_PORT=55415 \
    URBACKUP_BACKUP_VOLUMES=/backup

# Install dependencies in one layer and clean up
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        lsb-base \
        ca-certificates \
        mariadb-client \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Download and install UrBackup Client
RUN FILE="UrBackup%20Client%20Linux%20${VERSION}.sh" && \
    URL="https://hndl.urbackup.org/Client/${VERSION}/${FILE}" && \
    echo "Downloading UrBackup ${VERSION} from ${URL}" && \
    curl -fSL "${URL}" -o /root/install.sh && \
    sh /root/install.sh && \
    rm -f /root/install.sh && \
    # Configure for internet-only mode
    ([ ! -e /etc/default/urbackupclient ] || sed -i 's/INTERNET_ONLY=false/INTERNET_ONLY=true/' /etc/default/urbackupclient) && \
    ([ ! -e /etc/sysconfig/urbackupclient ] || sed -i 's/INTERNET_ONLY=false/INTERNET_ONLY=true/' /etc/sysconfig/urbackupclient) && \
    # Create backup directory
    mkdir -p /backup

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep urbackupclientbackend || exit 1

# Volume for backups
VOLUME ["/backup"]

# Labels for metadata
LABEL org.opencontainers.image.source="https://github.com/uroni/urbackup_backend" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.description="UrBackup Client ${VERSION}"

# Entrypoint and default command
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["--internet-only"]