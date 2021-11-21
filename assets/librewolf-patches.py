#!/usr/bin/env python3

import os
import sys
import optparse
import time
import glob


start_time = time.time()


parser = optparse.OptionParser()
parser.add_option('-n', '--no-execute', dest='no_execute', default=False, action="store_true")
parser.add_option('-P', '--no-settings-pane', dest='settings_pane', default=True, action="store_false")
options, args = parser.parse_args()

#
# general functions
#

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
        dir = "librewolf-{}".format(version)
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



def librewolf_patches():

    enter_srcdir()
    # create the right mozconfig file..
    exec('cp -v ../assets/mozconfig .')

    # copy branding files..
#    exec("cp -vr ../work/common/source_files/browser .")
    exec("cp -vr ../themes/browser .")
#    exec("cp -v ../work/windows/files/configure.sh browser/branding/librewolf")

    # read lines of .txt file into 'patches'
    f = open('../assets/patches.txt'.format(version), "r")
    lines = f.readlines()
    f.close()
    patches = []
    for line in lines:
        patches.append('../'+line)

        
    for p in patches:
        patch(p)
        
    exec('mkdir -p lw-assets')
    
    # insert the settings pane source (experimental)
    if options.settings_pane:

        exec('rm -rf librewolf-pref-pane')
        exec('git clone https://gitlab.com/ohfp/librewolf-pref-pane.git')
        os.chdir('librewolf-pref-pane')
        exec('git diff 1fee314adc81000294fc0cf3196a758e4b64dace > ../lw-assets/librewolf-pref-pane.patch')
        os.chdir('..')        
        patch('lw-assets/librewolf-pref-pane.patch')
        exec('rm -rf librewolf-pref-pane')


    # copy the build-librewolf.py script into the source folder
    exec('cp -v ../assets/build-librewolf.py lw-assets')
    exec('wget -q "https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py"')
    exec('mv -v bootstrap.py lw-assets')
    leave_srcdir()
    



#
# Main functionality in this script..
#

if len(args) != 1:
    sys.stderr.write('error: please specify version of librewolf source')
    sys.exit(1)
version = args[0]
if not os.path.exists('librewolf-{}'.format(version) + '/configure.py'):
    sys.stderr.write('error: folder doesn\'t look like a Firefox folder.')
    sys.exit(1)

librewolf_patches()

sys.exit(0) # ensure 0 exit code
