#!/bin/sh

set -eu

export VERSION=${VERSION:-0.0.0}
export GOFLAGS="'-ldflags=-w -s \"-X=github.com/jmorganca/ollama/version.Version=$VERSION\" \"-X=github.com/jmorganca/ollama/server.mode=release\"'"

BUILD_ARCH=${BUILD_ARCH:-"amd64 arm64"}
mkdir -p dist

for TARGETARCH in ${BUILD_ARCH}; do
    docker build --platform=linux/$TARGETARCH --build-arg=GOFLAGS --build-arg=CGO_CFLAGS --build-arg=OLLAMA_CUSTOM_CPU_DEFS -f Dockerfile.build -t builder:$TARGETARCH .
    docker create --platform linux/$TARGETARCH --name builder-$TARGETARCH builder:$TARGETARCH
    docker cp builder-$TARGETARCH:/go/src/github.com/jmorganca/ollama/ollama ./dist/ollama-linux-$TARGETARCH
    docker rm builder-$TARGETARCH
done
