## Building LibreWolf from source:
First, let's [download the latest tarball](https://gitlab.com/stanzabird/source/-/jobs/artifacts/main/raw/librewolf-94.0.2.source.tar.gz?job=build-job).

Next, we set a _version_ variable and creat ourselves a build folder.
```
export version=$(cat version)
mkdir build
cd build
tar xf ../librewolf-$(version).source.tar.gz
```
Next step, if you have not done so already, you must create the build environment:
```
cp librewolf-$(version)/lw-assets/bootstrap.py .
python3 bootstrap.py --no-interactive --application-choice=browser
```
It takes about an hour for me to complete, but it needs to be done only once. This step might fail and cause problems. Why Mozilla has no separate 'install-buildenv.py' is a bit beyond me. I would have liked to be able to set up the build environment in one step, in a second step checkout the entire mozilla source, or in our case, use our own source.

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
