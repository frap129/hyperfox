## The LibreWolf build instructions

First, let's **[download the latest tarball](https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-96.0.3-1.source.tar.gz?job=Build)**. This tarball is the latest produced by the [CI](https://gitlab.com/librewolf-community/browser/source/-/jobs).
```
tar xf <tarball>
cd <folder>
make bootstrap build package run
```
#### How to make a patch

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
cd into it, build the LibreWolf tarball, bootstrap the buld environment, and finally, perform the build:
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
