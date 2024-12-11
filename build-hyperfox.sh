#!/usr/bin/env bash

podman build builder -t hyperfox-builder
podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-builder
