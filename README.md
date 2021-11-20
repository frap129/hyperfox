## Building
First, let's head over to the [releases page](https://gitlab.com/stanzabird/source/-/releases); note and download the latest version. Once downloaded, extract it.
```
export version=94.0.1

wget -q https://fresh.librewolf.io/librewolf-$(version)/librewolf-$(version).source.tar.gz
tar xf librewolf-$(version).source.tar.gz
```
Next step, if you have not done so already, you must create the build environment:
```
python3 librewolf-$(version)/lw-assets/bootstrap.py
```
It takes about an hour for me to complete, but it needs to be done only once.

Now we're ready to actually build Librewolf:
```
cd librewplf-$(version)
./mach build
```
Then we can run it, 
```
./mach run
```
or make a package.
```
./mach package
```
