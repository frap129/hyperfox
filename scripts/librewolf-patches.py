#!/usr/bin/env python3

#
# The script that patches the firefox source into the librewolf source.
#


import os
import sys
import optparse
import time


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

def patch(patchfile):
    cmd = "patch -p1 -i {}".format(patchfile)
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
    
    # create the right mozconfig file..
    exec('cp -v ../assets/mozconfig.new mozconfig')

    # copy branding files..
    exec("cp -r ../themes/browser .")

    # copy the right search-config.json file
    exec('cp -v ../assets/search-config.json services/settings/dumps/main/search-config.json')

    # read lines of .txt file into 'patches'
    with open('../assets/patches.txt'.format(version), "r") as f:
        for line in f.readlines():
            patch('../'+line)

    # apply xmas.patch seperately because not all builders use this repo the same way, and
    # we don't want to disturbe those workflows.
    patch('../patches/xmas.patch')

    #
    # Create the 'lw' folder, it contains the librewolf.cfg and policies.json files.
    #
    
    #exec('mkdir -p lw')
    
    # getting the librewolf settings repository
    exec("cp -v ../submodules/settings/defaults/pref/local-settings.js lw/")
    exec("cp -v ../submodules/settings/distribution/policies.json lw/")
    exec("cp -v ../submodules/settings/librewolf.cfg lw/")

    
    # provide a script that fetches and bootstraps Nightly and some mozconfigs
    exec('cp -v ../scripts/mozfetch.sh lw/')
    exec('cp -v ../assets/mozconfig.new ../assets/mozconfig.new.without-bootstrap ../scripts/setup-wasi-linux.sh lw/')

    # override the firefox version
    for file in ["browser/config/version.txt", "browser/config/version_display.txt"]:
        with open(file, "w") as f:
            f.write("{}-{}".format(version,release))

    # generate locales
    exec("bash ../scripts/generate-locales.sh")
    
    leave_srcdir()



#
# Main functionality in this script.. which is to call librewolf_patches()
#

if len(args) != 2:
    sys.stderr.write('error: please specify version and release of librewolf source')
    sys.exit(1)
version = args[0]
release = args[1]
if not os.path.exists('librewolf-{}-{}'.format(version, release) + '/configure.py'):
    sys.stderr.write('error: folder doesn\'t look like a Firefox folder.')
    sys.exit(1)

librewolf_patches()

sys.exit(0) # ensure 0 exit code
