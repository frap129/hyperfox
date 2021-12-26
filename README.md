## Building LibreWolf from source:

First, let's **[download the latest tarball](https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-95.0.2.source.tar.gz?job=build-job)**. This tarball is the latest produced by the CI.

To download the latest from a script, use wget/curl like this:
```
export version=95.0.2 # example
wget -O librewolf-$(version).source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$(version).source.tar.gz?job=build-job
curl -L -o librewolf-$(version).source.tar.gz https://gitlab.com/librewolf-community/browser/source/-/jobs/artifacts/main/raw/librewolf-$(version).source.tar.gz?job=build-job
```

This should be enough for builders to create librewolfies, a more detailed description is in the works with documentation in: CONTRIBUTING.md
