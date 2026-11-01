#!/bin/sh
set -eu

version=$1
release=$2

# Patch checksums of third_party patched crates
sed -i 's/8b28662ab15031496b495fa701f211aa336c119b99c25b522be6f396a1231891/c07441d4938b3331ea81162efc079a489c7c75c48f63b6d6741f699ab420de73/g' third_party/rust/glean-core/.cargo-checksum.json
sed -i 's/ada8f059f0fa8a3a82315606318429d3a70200bbb2886d1a1bcaad2856a6303b/70a4a176b6494fce419e590180bc9c631945282ded0ab05bc1591bdd37b65093/g' third_party/rust/glean-core/.cargo-checksum.json

# Have all pings follow the datareporting preference
find . -type f -name '*.yaml' -exec sed -i 's/follows_collection_enabled: false/follows_collection_enabled: true/g' {} +

# Remove OpenAI integration
rm -vf toolkit/components/ml/content/backends/OpenAIPipeline.mjs
rm -vrf toolkit/components/ml/vendor/openai/

# Add our display versioning for MOZ_PKG_VERSION
sed -i "s/^export MOZ_PKG_VERSION=.*/export MOZ_PKG_VERSION=${version}-${release}/" ../assets/mozconfig.new

# Create the right mozconfig file..
cp -v ../assets/mozconfig.new mozconfig

# Copy branding files..
cp -vr ../themes/browser/ .

# Copy our patch icons
cp -v ../assets/icons/* browser/themes/shared/icons/

# Copy the right search-config.json-v2 file and search-config-icons file
cp -v ../assets/search-config-v2.json services/settings/dumps/main/search-config-v2.json
cp -v ../assets/search-config-icons.json services/settings/dumps/main/search-config-icons.json

# Add mojeek
cp -v ../assets/2c4b8834-030c-4097-a887-c7506689095c services/settings/dumps/main/search-config-icons
cp -v ../assets/2c4b8834-030c-4097-a887-c7506689095c.meta.json services/settings/dumps/main/search-config-icons

# Copy our public signing keys
cp -v ../assets/marsigner.der toolkit/mozapps/update/updater/release_primary.der
cp -v ../assets/marsigner2.der toolkit/mozapps/update/updater/release_secondary.der

# Apply most recent `settings` repository files.
mkdir -p lw
cp -v ../settings/librewolf.cfg lw/
cp -v ../settings/distribution/policies.json lw/
cp -v ../settings/defaults/pref/local-settings.js lw/

# Apply our patches
if command -v gpatch >/dev/null 2>&1; then
  patch_cmd=gpatch
elif command -v patch >/dev/null 2>&1; then
  patch_cmd=patch
else
  echo "error: neither gpatch nor patch is installed" >&2
  exit 1
fi

while read -r file || [ -n "$file" ]; do
  printf 'Applying %s\n' "$file"
  "$patch_cmd" -p1 -i "$file"
done < "../assets/patches.txt"

# copy our extra files
cp ../patches/pref-pane/category-librewolf.svg browser/themes/shared/preferences/category-librewolf.svg
cp ../patches/pref-pane/librewolf.css browser/themes/shared/preferences/librewolf.css
cp ../patches/pref-pane/librewolf.inc.xhtml browser/components/preferences/librewolf.inc.xhtml
cp ../patches/pref-pane/librewolf.js browser/components/preferences/librewolf.js

# Override the firefox version
printf '%s' "$version" > browser/config/version.txt
printf '%s-%s' "$version" "$release" > browser/config/version_display.txt

if [ "${SKIP_FETCHING_LOCALES+x}" != x ]; then
    echo "-> Downloading locales from https://librewolf.dev/mirror/firefox-l10n"
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    git clone --depth=1 https://librewolf.dev/mirror/firefox-l10n "$tmpdir/l10n"
    rm -rf "$tmpdir/l10n/.git" "$tmpdir/l10n/.github" "$tmpdir/l10n/LICENSE" "$tmpdir/l10n/README"
    mv "$tmpdir/l10n" "lw/l10n"
else
    echo "-> Using pre-fetched locales"
fi

# Replace hardcoded "Firefox" strings
echo "-> Patching appstrings.properties"
find . -path '*/appstrings.properties' -exec sed -i 's/Firefox/LibreWolf/g' {} \;

echo "-> Applying LibreWolf locales"
find ../l10n -type f ! -name '*.md' -print |
while read -r src; do
    rel=${src#../l10n/}

    case "$rel" in
        en-US/*)
            rest=${rel#en-US/}
            locale=${rest%%/*}
            target=$locale/locales/en-US${rest#"$locale"}
            ;;
        *)
            target=lw/l10n/$rel
            ;;
    esac

    mkdir -p "${target%/*}"

    case "${target##*/}" in
        *".inc"*)
            name=$(printf '%s\n' "${target##*/}" | sed 's/\.inc//g')
            target=${target%/*}/$name

            printf '%s >> %s\n' "$src" "$target"
            [ -f "$target" ] || printf "warning: target file %s doesn't exist\n" "$target"
            printf '\n\n' >> "$target"
            cat "$src" >> "$target"
            ;;
        *)
            printf '%s > %s\n' "$src" "$target"
            cat "$src" > "$target"
            ;;
    esac
done
