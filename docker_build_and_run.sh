#!/bin/bash
set -e

# Create docker image to reproduce issue
docker build - -t protobuf-tsan-test:latest < Dockerfile

# Run test from docker image with current user permissions
docker run -u "$(id -u)":"$(id -g)":root --rm -v "$PWD":/src -w /src --entrypoint bash protobuf-tsan-test:latest ./build_and_run.sh
