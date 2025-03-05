#!/usr/bin/env bash

srcdir="/src/librewolf-$(cat /src/version)-$(cat /src/release)"
export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=pip
export MOZBUILD_STATE_PATH="$srcdir/mozbuild"
export MOZ_BUILD_DATE="$(date -u${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH} +%Y%m%d%H%M%S)"
export MOZ_NOSPAM=1
#export MOZ_RUST_VERSION="1.81.0"
export SCCACHE_DIR="/src/sccache"
export SCCACHE_DIRECT=true

cd /src || exit
make dir || exit
make bootstrap || exit

# Build without PGO
cat >$srcdir/mozconfig assets/mozconfig.new - <<END
ac_add_options --enable-profile-generate=cross
ac_add_options --disable-elf-hack
ac_add_options --enable-linker=mold
ac_add_options --disable-lto
END
make build || exit

# Generate PGO profdata
(
  cd $srcdir || exit
  ./mach package
  LLVM_PROFDATA="$MOZBUILD_STATE_PATH/clang/bin/llvm-profdata" JARLOG_FILE="$srcdir/jarlog" \
    dbus-run-session \
    wlheadless-run -c weston --width=1920 --height=1080 -- \
    ./mach python build/pgo/profileserver.py
  ./mach clobber objdir
)

# Final build
cat >$srcdir/mozconfig assets/mozconfig.new - <<END
ac_add_options --enable-elf-hack=relr
ac_add_options --enable-linker=lld
ac_add_options --enable-lto=cross,full
ac_add_options --enable-profile-use=cross
ac_add_options --with-pgo-profile-path=$srcdir/merged.profdata
ac_add_options --with-pgo-jarlog=$srcdir/jarlog
END
make build || exit
make package || exit
