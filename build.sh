#!/bin/bash
set -x

# Accepted values for ARCH are amd64, armhf, arm64, i386
ARCH=${1:-amd64}
VERSION=${2:-2.5.26}
DEBIAN_VERSION=bookworm

docker build \
              --build-arg ARCH=${ARCH} \
              --build-arg VERSION=${VERSION} \
              --build-arg IMAGE_ARCH=$([ "${ARCH}" == "armhf" ] && echo "arm32v7/debian:$DEBIAN_VERSION" || ([ "${ARCH}" == "arm64" ] && echo "arm64v8/debian:$DEBIAN_VERSION") || ([ "${BUILD_ARCH}" == "i386" ] && echo "i386/debian:$DEBIAN_VERSION") || echo "debian:$DEBIAN_VERSION") \
              -t urbackup-client:${VERSION}_${ARCH} \
              .
