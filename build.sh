#!/bin/bash
set -x

# Accepted values for ARCH are amd64, armhf, arm64, i386
ARCH=${1:-amd64}
VERSION=${2:-2.4.12}

docker build \
              --build-arg ARCH=${ARCH} \
              --build-arg VERSION=${VERSION} \
              --build-arg IMAGE_ARCH=$([ "${ARCH}" == "armhf" ] && echo "arm32v7/debian:buster" || ([ "${ARCH}" == "arm64" ] && echo "arm64v8/debian:buster") || ([ "${BUILD_ARCH}" == "i386" ] && echo "i386/debian:buster") || echo "debian:buster") \
              -t urbackup-server:${VERSION}_${ARCH} \
              .
