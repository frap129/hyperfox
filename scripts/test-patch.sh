#!/usr/bin/bash
set -eu

if [ $# -ne 1 ]; then
  echo "Usage: $0 <path to patch>"
  exit 1
fi

if [ "$1" == "${1%.patch}" ]; then
  echo "Error: '$1' does not seem to be a patch."
  exit 1
fi

cd "$(dirname "$0")/.."
version="$(cat version)"

if [ -d "firefox-$version" ]; then
  echo "-> Removing old 'firefox-$version'"
  rm -rf "firefox-$version"
fi

echo "-> Extracting 'firefox-$version.source.tar.xz'"
make "firefox-$version.source.tar.xz"
tar xf "firefox-$version.source.tar.xz"
cd "firefox-$version"

echo "-> Settings up git"
git init
files="$(cat ../$1 | grep '+++ b/' | sed 's/\+\+\+ b\///')"
echo "$files" | xargs touch
echo "$files" | xargs git add

echo "-> Done"
echo "You can now apply the patch with:"
echo "  cd 'firefox-$version' && patch -p1 -i '$(readlink -f ../$1)'"
