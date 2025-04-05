#!/usr/bin/env bash

# deb.sh - make the debian style `.deb` package file.

set -eu

VERSION="$(cat /src/version)-$(cat /src/release)"
DIST_TAR=/src/hyperfox-${VERSION}.en-US.linux-x86_64.tar.xz

deb_arch() {
    case "$1" in
    x86_64) echo "amd64" ;;
    *) echo "$1" ;;
    esac
}

function build_deb() {
    # create package structure from dist bundle
    mkdir hyperfox
    cd hyperfox
    mkdir -p usr/share/hyperfox
    mv ../dist/* usr/share/hyperfox

    mkdir -p usr/bin
    cd usr/bin
    ln -s ../share/hyperfox/hyperfox
    cd ../..

    # add the application icon
    mkdir -p usr/share/applications
    mkdir -p usr/share/icons/hicolor/16x16/apps
    mkdir -p usr/share/icons/hicolor/32x32/apps
    mkdir -p usr/share/icons/hicolor/64x64/apps
    mkdir -p usr/share/icons/hicolor/128x128/apps
    cp usr/share/hyperfox/browser/chrome/icons/default/default16.png usr/share/icons/hicolor/16x16/apps/hyperfox.png
    cp usr/share/hyperfox/browser/chrome/icons/default/default32.png usr/share/icons/hicolor/32x32/apps/hyperfox.png
    cp usr/share/hyperfox/browser/chrome/icons/default/default64.png usr/share/icons/hicolor/64x64/apps/hyperfox.png
    cp usr/share/hyperfox/browser/chrome/icons/default/default128.png usr/share/icons/hicolor/128x128/apps/hyperfox.png
    cp ../hyperfox.desktop usr/share/applications/hyperfox.desktop

    # Generate debian control file
    mkdir -p DEBIAN
    cat <<EOF >DEBIAN/control
Architecture: $(deb_arch "x86_64")
Depends: libasound2 (>= 1.0.16), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.18), libcairo-gobject2 (>= 1.10.0), libcairo2 (>= 1.10.0), libdbus-1-3 (>= 1.5.12), libfontconfig1 (>= 2.11), libfreetype6 (>= 2.3.5), libgcc1 (>= 1:4.1.1), libgdk-pixbuf2.0-0 (>= 2.22.0) | libgdk-pixbuf-2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.0), libgtk-3-0 (>= 3.13.7), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libstdc++6 (>= 4.8), libx11-6, libx11-xcb1, libxcb-shm0, libxcb1, libxcomposite1 (>= 1:0.3-1), libxcursor1 (>> 1.1.2), libxdamage1 (>= 1:1.1), libxext6, libxfixes3, libxi6, libxrandr2 (>= 2:1.4.0), libxrender1, zstd
Description: The Hyperfox Browser
Essential: no
Installed-Size: $(du -B 1MB -ks usr|cut -f 1) MB
Maintainer: Joe Maples <joe@maples.dev>
Package: hyperfox
Priority: optional
Provides: gnome-www-browser, www-browser, x-www-browser
Section: web
Version: ${1}
EOF

    # Make .deb package
    cd ..
    mv hyperfox hyperfox-$VERSION
    dpkg-deb --build  --root-owner-group hyperfox-$VERSION

    # Sign the deb file if private key is provided and we have dpkg-sig available
    if [ -n "${SIGNING_KEY_FPR:-}" ] && command -v dpkg-sig &>/dev/null; then
        echo "-> Signing the DEB" >&2
        dpkg-sig --sign builder hyperfox-${VERSION}.deb
    fi
}

echo "-> Fetching Hyperfox v$VERSION dist bundle" >&2
tmpdir=$(mktemp -d)
(
    cd $tmpdir
    tar xf "$DIST_TAR"
    mv hyperfox dist
)

echo "-> Building Debian package" >&2
sed "s/MYDIR/\/usr\/share\/hyperfox/g" <linux.hyperfox.desktop.in >$tmpdir/hyperfox.desktop
(cd $tmpdir && build_deb $VERSION)

echo "-> Cleaning up" >&2
mv $tmpdir/hyperfox-$VERSION.deb .
rm -rf $tmpdir

