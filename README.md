## LibreWolf build instructions

First, let's **[download the latest tarball](https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-96.0.3-2.source.tar.gz?job=Build)**. This tarball is the latest produced by the [CI](https://gitlab.com/librewolf-community/browser/source/-/jobs).
```
tar xf <tarball>
cd <folder>
make bootstrap build package run
```
#### How to make a patch:

The easiest way to make patches is to go to the LibreWolf source folder:
```
cd librewolf-$(cat version)
git init
git add <path_to_file_you_changed>
git commit -am initial-commit
git diff > ../mypatch.patch
```
We have Gitter / Matrix rooms, and on the website we have links to the various issue trackers.

#### Building LibreWolf with git:

1. Clone the git repository via https:
```
git clone --recursive https://gitlab.com/librewolf-community/browser/source.git
```
or Git:
```
git clone --recursive git@gitlab.com:librewolf-community/browser/source.git
```
cd into it, build the LibreWolf tarball, bootstrap the build environment, and finally, perform the build:
```
cd source
make all
make bootstrap
make build
```
After that, you can either build a tarball from it, or run it:
```
make package
make run
```
#### How to create a patch for problems in Mozilla's [Bugzilla](https://bugzilla.mozilla.org/).

Well, first of all:

* [Create an account](https://bugzilla.mozilla.org/createaccount.cgi).
* Handy link: [Bugs Filed Today](https://bugzilla.mozilla.org/buglist.cgi?cmdtype=dorem&remaction=run&namedcmd=Bugs%20Filed%20Today&sharer_id=1&list_id=15939480).
* The essential: [Firefox Source Tree Documentation](https://firefox-source-docs.mozilla.org/).

Now that you have a patch in LibreWolf, that's not enough to upload to Mozilla. See, Mozilla only accepts patches against Nightly. So here is how to do that:
```
hg clone https://hg.mozilla.org/mozilla-unified
cd mozilla-unified
hg update
MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser
./mach build
./mach run
```
Now you can apply your patch to Nightly:
```
patch -p1 -i ../mypatch.patch
```
Now you let Mercurial create the patch:
```
hg diff > ../my-nightly-patch.patch
```
And it can be uploaded to Bugzilla.

##### *(copy of Mozilla readme)* Now the fun starts

Time to start hacking! You should join us on [Matrix](https://chat.mozilla.org/), say hello in the [Introduction channel](https://chat.mozilla.org/#/room/#introduction:mozilla.org), and [find a bug to start working on](https://codetribute.mozilla.org/). See the [Firefox Contributors’ Quick Reference](https://firefox-source-docs.mozilla.org/contributing/contribution_quickref.html#firefox-contributors-quick-reference) to learn how to test your changes, send patches to Mozilla, update your source code locally, and more.

#### Hey, I'm using a Mac or Windows :(
We understand, life isn't always fair 😺. The same steps as above do apply, you'll just have to walk through the beginning part of the guides for [MacOS](https://firefox-source-docs.mozilla.org/setup/macos_build.html), [Windows](https://firefox-source-docs.mozilla.org/setup/windows_build.html).
