## Building LibreWolf from source:
First, let's [download the latest version](https://gitlab.com/stanzabird/source/-/jobs/artifacts/main/raw/librewolf-94.0.2.source.tar.gz?job=build-job). Once downloaded, extract it.
```
export version=$(cat version)
mkdir build
cd build

wget -q https://fresh.librewolf.io/librewolf-$(version)/librewolf-$(version).source.tar.gz
tar xf librewolf-$(version).source.tar.gz
```
Next step, if you have not done so already, you must create the build environment:
```
cp librewolf-$(version)/lw-assets/bootstrap.py .
python3 bootstrap.py --no-interactive --application-choice=browser
```
It takes about an hour for me to complete, but it needs to be done only once. This step might fail and cause problems.

Now we're ready to actually build LibreWolf:
```
cd librewolf-$(version)
./mach build
```
Also takes me an hour. Then, we can run it:
```
./mach run
```
Or make a package:
```
./mach package
```
## Building LibreWolf source tarball:
You don't need the build environment for this. If you don't have write access, just:
```
git clone https://gitlab.com/stanzabird/source.git
cd source
make all
```
If you **do** have write access, we're first gonna check for a newer version of Firefox:
```
git clone git@gitlab.com:<your_username>/source.git
cd source
make check
```
If there is a new version, it's a good time to git commit and trigger a CI build job.
```
git commit -am v$(cat version) && git push
```
To build the source archive:
```
make all
```
