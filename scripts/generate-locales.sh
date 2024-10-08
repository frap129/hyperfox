#!/usr/bin/bash

if [ ! -f browser/locales/shipped-locales ]; then
  echo "ERROR: Run this script from the root of the LibreWolf source code"
  exit 1
fi

echo "-> Downloading locales"
rm -rf browser/locales/l10n
curl -o browser/locales/l10n.zip "https://codeload.github.com/mozilla-l10n/firefox-l10n/zip/refs/heads/main"
unzip -qo browser/locales/l10n.zip -d browser/locales/
mv browser/locales/firefox-l10n-main browser/locales/l10n
rm -f browser/locales/l10n.zip
