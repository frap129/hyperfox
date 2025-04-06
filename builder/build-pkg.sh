#!/usr/bin/env bash
set -eu

VERSION="$(cat /src/version)"
RELEASE="$(cat /src/release)"
DIST="/src/out/hyperfox-${VERSION}-${RELEASE}.en-US.linux-x86_64.tar.xz"
SHA256SUM="$(sha256sum $DIST | cut -d ' ' -f1)"

sed -e "s/VERSION/${VERSION}/g" \
  -e "s/RELEASE/${RELEASE}/g" \
  -e "s/SHA256SUM/${SHA256SUM}/g" \
  </src/builder/PKGBUILD.in >/src/builder/pkgbuild/PKGBUILD

cd /src/builder/pkgbuild
cp $DIST .
makepkg --printsrcinfo >.SRCINFO
makepkg -fcCs --noconfirm

mv hyperfox-browser-bin-${VERSION}-${RELEASE}-x86_64.pkg.tar.* /src/out
