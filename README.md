# LibreWolf Source Repository

This repository contains all the patches and theming that make up LibreWolf, as well as scripts and a Makefile to build LibreWolf. There also is the [Settings repo](https://gitlab.com/librewolf-community/settings), which contains the LibreWolf prefs.

## Active repositories and projects

List of browser build sub projects. These are the locations where people have their repositories and build artifacts.

Currently active build repositories:
* [Arch](https://gitlab.com/librewolf-community/browser/arch): Arch Linux
* [Bsys5](https://gitlab.com/librewolf-community/browser/bsys5): .deb/.rpm for Mint, Fedora, Ubuntu; .dmg for MacOS.
* [Debian](https://gitlab.com/librewolf-community/browser/debian): bgstack15 version
* [Fedora](https://gitlab.com/librewolf-community/browser/fedora): bgstack15 version
* [Flatpak](https://gitlab.com/librewolf-community/browser/flatpak): Flatpak
* [Gentoo](https://gitlab.com/librewolf-community/browser/gentoo): Gentoo
* [Linux](https://gitlab.com/librewolf-community/browser/linux): Flatpak, AppImage, Arch and other Linux builds of the LibreWolf browser.
* [MacOS](https://gitlab.com/librewolf-community/browser/macos): The macOS build of LibreWolf.
* [OpenBSD](https://librewolf.net/installation/openbsd/): OpenBSD page
* [Windows](https://gitlab.com/librewolf-community/browser/windows): LibreWolf builds for Windows.

Currently active forks:
* Cachy-Browser: https://github.com/cachyos/cachyos-browser-settings
* FireDragon: https://github.com/dr460nf1r3/firedragon-browser

## LibreWolf build instructions

There are two ways to build LibreWolf. You can either use the source tarball or compile directly with this repository.

### Building from the Tarball

First, let's **[download the latest tarball](https://gitlab.com/librewolf-community/browser/source/-/releases)**. This tarball is the latest produced by the [CI](https://gitlab.com/librewolf-community/browser/source/-/jobs). You can also check the sha256sum of the tarball there.

```
tar xf <tarball>
cd <folder>
```

Then, you have to bootstrap your system to be able to build LibreWolf. You only have to do this one time. It is done by running the following commands:

```
./mach --no-interactive bootstrap --application-choice=browser
./lw/setup-wasi-linux.sh
```

Finally you can build LibreWolf and then package or run it with the following commands:

```
./mach build
./mach package
# OR
./mach run
```

### Building with this Repository

First, clone this repository with Git:

```
git clone --recursive https://gitlab.com/librewolf-community/browser/source.git librewolf-source
cd librewolf-source
```

Next, build the LibreWolf source code with the following command:

```
make dir
```

After that, you have to bootstrap your system to be able to build LibreWolf. You only have to do this one time. It is done by running the following command:

```
make bootstrap
```

Finally you can build LibreWolf and then package or run it with the following commands:

```
make build
make package
# OR
make run
```

## Development Notes

### How to make a patch

The easiest way to make patches is to go to the LibreWolf source folder:
```
cd librewolf-$(cat version)
git init
git add <path_to_file_you_changed>
git commit -am initial-commit
git diff > ../mypatch.patch
```
We have Gitter / Matrix rooms, and on the website we have links to the various issue trackers.

### How to work on an existing patch

The easiest way to make patches is to go to the LibreWolf source folder:
```
make fetch # get the firefox tarball
./scripts/git-patchtree.sh patches/sed-patches/disable-pocket.patch
```
Now change the source tree the way you want, keeping in mind to `git add` new files. When done, you can create the new patch with:
```
cd firefox-<version>
git diff 4b825dc642cb6eb9a060e54bf8d69288fbee4904 HEAD > ../my-patch-name.patch
```
This ID is the hash value of the first commit, which is called `initial`. Dont forget to commit changes before doing this diff, or the patch will be incomplete.


### How to create a patch for problems in Mozilla's [Bugzilla](https://bugzilla.mozilla.org/).

Well, first of all:

* [Create an account](https://bugzilla.mozilla.org/createaccount.cgi).
* Handy link: [Bugs Filed Today](https://bugzilla.mozilla.org/buglist.cgi?cmdtype=dorem&remaction=run&namedcmd=Bugs%20Filed%20Today&sharer_id=1&list_id=15939480).
* The essential: [Firefox Source Tree Documentation](https://firefox-source-docs.mozilla.org/).

Now that you have a patch in LibreWolf, that's not enough to upload to Mozilla. See, Mozilla only accepts patches against Nightly. So here is how to do that:

If you have not done already, create the `mozilla-unified` folder and build Firefox with it:
```
hg clone https://hg.mozilla.org/mozilla-unified
cd mozilla-unified
hg update
MOZBUILD_STATE_PATH=$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser
./mach build
./mach run
```
If you skipped the previous step, you could ensure that you're up to date with:
```
cd mozilla-unified
hg pull
hg update
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

##### *(excerpt from the Mozilla readme)* Now the fun starts

Time to start hacking! You should join us on [Matrix](https://chat.mozilla.org/), say hello in the [Introduction channel](https://chat.mozilla.org/#/room/#introduction:mozilla.org), and [find a bug to start working on](https://codetribute.mozilla.org/). See the [Firefox Contributors’ Quick Reference](https://firefox-source-docs.mozilla.org/contributing/contribution_quickref.html#firefox-contributors-quick-reference) to learn how to test your changes, send patches to Mozilla, update your source code locally, and more.

## Hey, I'm using MacOS or Windows :(
We understand, life isn't always fair 😺. The same steps as above do apply, you'll just have to walk through the beginning part of the guides for:
* [MacOS](https://firefox-source-docs.mozilla.org/setup/macos_build.html): The cross-compiled Mac .dmg files are somewhat new. They should work, perhaps with the exception of the `make setup-wasi` step.
* [Windows](https://firefox-source-docs.mozilla.org/setup/windows_build.html): Building on Windows is not very well tested.

Help with testing these targets is always welcome.
