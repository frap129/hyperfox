#!/usr/bin/env bash

set -e

fetch_and_extract() {
    rm -rf version release
    wget -q -O version "https://gitlab.com/librewolf-community/browser/source/-/raw/main/version"
    wget -q -O release "https://gitlab.com/librewolf-community/browser/source/-/raw/main/release"
    
    rm -f "librewolf-$(cat version)-$(cat release).source.tar.gz"
    wget -O "librewolf-$(cat version)-$(cat release).source.tar.gz" "https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$(cat version)-$(cat release).source.tar.gz?job=build-job"
    
    rm -rf librewolf-$(cat version)
    tar xf librewolf-$(cat version)-$(cat release).source.tar.gz

    # here would be a great spot to insert system dependent stuff like mozconfig/patches.
}

build() {
    cd librewolf-$(cat version)
      ./mach build
      ./mach package
    cd ..
}

artifacts() {
    # ... Here we do system dependent stuff like builing rpm's, setup.exe or other formats we distribute in
}

build_all() {
    fetch_and_extract
    build
    artifacts
}

build_all
