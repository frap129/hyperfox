#!/usr/bin/env bash

cd /src || exit
make dir
make bootstrap
dbus-run-session \
  xvfb-run -s "-screen 0 1920x1080x24 -nolisten local" \
  bash -c "make build || make build"
make package
