#!/bin/bash

# Script to build and run tests in a Linux container

echo "Building Docker image for Linux testing..."
docker build -t swift-erlang-actor-system-linux .

echo "Running tests in Linux container..."
docker run --rm swift-erlang-actor-system-linux

# Optionally run with volume mounts for faster development
# docker run --rm -v "$(pwd)/Sources:/app/Sources:ro" -v "$(pwd)/Tests:/app/Tests:ro" swift-erlang-actor-system-linux