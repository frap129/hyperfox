## Building LibreWolf from source:

First, let's **[download the latest tarball](https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-95.0.2.source.tar.gz?job=build-job)**. This tarball is the latest produced by the CI.

To download the latest from a script, use wget/curl like this:
```
export version=95.0.2 # example
wget -O librewolf-$(version).source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$(version).source.tar.gz?job=build-job
curl -L -o librewolf-$(version).source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$(version).source.tar.gz?job=build-job
```

Next, we create ourselves a build folder and extract the tarball.

```
mkdir build
cd build
tar xf ../librewolf-$(version).source.tar.gz
```
Next step, if you have not done so already, you must create the build environment:
```
librewolf-$(version)/lw/mozfetch.sh
```
It takes about an hour for me to complete, but it needs to be done only once. This step might fail and cause problems. Hack a bit, and if that fails you can ask on our Gitter/matrix channel.

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

Luckly, you don't need the build environment for this. If you don't have write access, just:
```
git clone https://gitlab.com/librewolf-community/browser/source.git
cd source
make all
```
If you **do** have write access, we're first gonna check for a newer version of Firefox:
```
git clone git@gitlab.com:librewolf-community/browser/source.git
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
If you have a working build environment, you can build librewolf with:
```
make librewolf
```
This extracts the source, and then tries to `./mach build && ./mach package`.
