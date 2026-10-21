#!/usr/bin/env python3

#
# The script that patches the firefox source into the librewolf source.
#


import os
import shutil
import sys
import optparse
import time
from pathlib import Path
from tempfile import TemporaryDirectory


#
# general functions, skip these, they are not that interesting
#

start_time = time.time()
parser = optparse.OptionParser()
parser.add_option('-n', '--no-execute', dest='no_execute', default=False, action="store_true")
parser.add_option('-P', '--no-settings-pane', dest='settings_pane', default=True, action="store_false")
options, args = parser.parse_args()


def script_exit(statuscode):
    if (time.time() - start_time) > 60:
        # print elapsed time
        elapsed = time.strftime("%H:%M:%S", time.gmtime(time.time() - start_time))
        print("\n\aElapsed time: {elapsed}")
        sys.stdout.flush()

    sys.exit(statuscode)

def exec(cmd, exit_on_fail = True, do_print = True):
    if cmd != '':
        if do_print:
            print(cmd)
            sys.stdout.flush()
        if not options.no_execute:
            retval = os.system(cmd)
            if retval != 0 and exit_on_fail:
                print("fatal error: command '{}' failed".format(cmd))
                sys.stdout.flush()
                script_exit(1)
            return retval
        return None

PATCH_BIN = shutil.which("gpatch") or "patch"

def patch(patchfile):
    cmd = "{} -p1 -i {}".format(PATCH_BIN, patchfile)
    print("\n*** -> {}".format(cmd))
    sys.stdout.flush()
    if not options.no_execute:
        retval = os.system(cmd)
        if retval != 0:
            print("fatal error: patch '{}' failed".format(patchfile))
            sys.stdout.flush()
            script_exit(1)

def enter_srcdir(_dir = None):
    if _dir == None:
        dir = "librewolf-{}-{}".format(version, release)
    else:
        dir = _dir
    print("cd {}".format(dir))
    sys.stdout.flush()
    if not options.no_execute:
        try:
            os.chdir(dir)
        except:
            print("fatal error: can't change to '{}' folder.".format(dir))
            sys.stdout.flush()
            script_exit(1)

def leave_srcdir():
    print("cd ..")
    sys.stdout.flush()
    if not options.no_execute:
        os.chdir("..")



#
# This is the only interesting function in this script
#


def librewolf_patches():

    enter_srcdir()

    exec("sed -i 's/ada8f059f0fa8a3a82315606318429d3a70200bbb2886d1a1bcaad2856a6303b/70a4a176b6494fce419e590180bc9c631945282ded0ab05bc1591bdd37b65093/g' third_party/rust/glean-core/.cargo-checksum.json")
    exec("sed -i 's/1753c69b71ae24a9b339d98e9b71166740a15506cfc46245251eb63c0222568f/af3ae3d026bd2e26fd9cc7c710847ac4f853b0c899412ddc9ee7e0ef1027de87/g' third_party/rust/glean-core/.cargo-checksum.json")

    # Have all pings follow the datareporting preference
    exec("find . -type f -exec sed -i 's/follows_collection_enabled: false/follows_collection_enabled: true/g' {} +")

    # remove OpenAI integration
    exec('rm -vf toolkit/components/ml/content/backends/OpenAIPipeline.mjs')
    exec('rm -vrf toolkit/components/ml/vendor/openai')

    # Add our display versioning for MOZ_PKG_VERSION
    with open("../assets/mozconfig.new", "r") as f:
        text = f.read().replace(
            "export MOZ_PKG_VERSION=",
            f"export MOZ_PKG_VERSION={version}-{release}"
        )

    with open("../assets/mozconfig.new", "w") as f:
        f.write(text)

    # create the right mozconfig file..
    exec('cp -v ../assets/mozconfig.new mozconfig')

    # copy branding files..
    exec("cp -r ../themes/browser .")

    # copy our patch icons
    exec('cp -v ../assets/icons/* browser/themes/shared/icons/')

    # copy the right search-config.json-v2 file and search-config-icons file
    exec('cp -v ../assets/search-config-v2.json services/settings/dumps/main/search-config-v2.json')
    exec('cp -v ../assets/search-config-icons.json services/settings/dumps/main/search-config-icons.json')

    # add mojeek
    exec('cp -v ../assets/2c4b8834-030c-4097-a887-c7506689095c services/settings/dumps/main/search-config-icons')
    exec('cp -v ../assets/2c4b8834-030c-4097-a887-c7506689095c.meta.json services/settings/dumps/main/search-config-icons')

    # copy our public signing keys
    exec('cp -v ../assets/marsigner.der toolkit/mozapps/update/updater/release_primary.der')
    exec('cp -v ../assets/marsigner2.der toolkit/mozapps/update/updater/release_secondary.der')

    # read lines of .txt file into 'patches'
    with open('../assets/patches.txt', "r") as f:
        for line in f.readlines():
            patch('../'+line.strip())

    # apply xmas.patch seperately because not all builders use this repo the same way, and
    # we don't want to disturbe those workflows.
    patch('../patches/xmas.patch')

    #
    # Apply most recent `settings` repository files.
    #

    exec('mkdir -p lw')
    enter_srcdir('lw')
    exec('cp -v ../../settings/librewolf.cfg .')
    exec('cp -v ../../settings/distribution/policies.json .')
    exec('cp -v ../../settings/defaults/pref/local-settings.js .')
    leave_srcdir();



    #
    # pref-pane patches
    #

    # 1) patch it in
    patch('../patches/pref-pane/pref-pane-small.patch')
    # 2) new files
    exec('cp ../patches/pref-pane/category-librewolf.svg browser/themes/shared/preferences/category-librewolf.svg')
    exec('cp ../patches/pref-pane/librewolf.css browser/themes/shared/preferences/librewolf.css')
    exec('cp ../patches/pref-pane/librewolf.inc.xhtml browser/components/preferences/librewolf.inc.xhtml')
    exec('cp ../patches/pref-pane/librewolf.js browser/components/preferences/librewolf.js')

    # provide a script that fetches and bootstraps Nightly and some mozconfigs
    exec('cp -v ../scripts/mozfetch.sh lw/')
    exec('cp -v ../assets/mozconfig.new lw/')

    # override the firefox version
    with open("browser/config/version.txt", "w") as f:
        f.write(version)

    with open("browser/config/version_display.txt", "w") as f:
        f.write("{}-{}".format(version, release))

    if os.environ.get("SKIP_FETCHING_LOCALES") is None:
        print("-> Downloading locales from https://librewolf.dev/mirror/firefox-l10n")
        with TemporaryDirectory() as tmpdir:
            exec(f"git clone --depth=1 https://librewolf.dev/mirror/firefox-l10n {tmpdir}/l10n")
            exec(f"rm -rf {tmpdir}/l10n/.git {tmpdir}/l10n/.github {tmpdir}/l10n/LICENSE {tmpdir}/l10n/README")
            exec(f"mv {tmpdir}/l10n lw/l10n")
    else:
        print("-> Using pre-fetched locales")

    print("-> Patching appstrings.properties")
    # Why is "Firefox" hardcoded there???
    exec("find . -path '*/appstrings.properties' -exec sed -i s/Firefox/LibreWolf/ {} \\;")

    print("-> Applying LibreWolf locales")
    l10n_dir = Path("..", "l10n")
    for source_path in l10n_dir.rglob("*"):
        if source_path.is_dir() or source_path.name.endswith(".md"):
            continue

        rel_path = source_path.relative_to(l10n_dir)
        if rel_path.parts[0] == "en-US":
            target_path = Path(
                rel_path.parts[1],
                "locales", "en-US",
                *rel_path.parts[2:]
            )
        else:
            target_path = Path(
                "lw", "l10n",
                *rel_path.parts
            )

        target_path.parent.mkdir(parents=True, exist_ok=True)

        write_mode = "w"
        if ".inc" in target_path.name:
            target_path = target_path.with_name(target_path.name.replace(".inc", ""))
            write_mode = "a"

        print(f"{source_path} {'>' if write_mode == 'w' else '>>'} {target_path}")

        if not target_path.exists() and write_mode == "a":
            print(f"warning: target file {target_path} doesn't exist")
        with open(target_path, write_mode) as target_file:
            with open(source_path, "r") as source_file:
                target_file.write(("\n\n" if write_mode == "a" else "") + source_file.read())

    leave_srcdir()



#
# Main functionality in this script.. which is to call librewolf_patches()
#

if len(args) != 2:
    sys.stderr.write('error: please specify version and release of librewolf source')
    sys.exit(1)
version = args[0]
release = args[1]
srcdir = "librewolf-{}-{}".format(version, release)
if not os.path.exists(srcdir + '/configure.py'):
    sys.stderr.write('error: folder doesn\'t look like a Firefox folder.')
    sys.exit(1)

librewolf_patches()

sys.exit(0) # ensure 0 exit code
