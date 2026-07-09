# Build hyperfox and all packages
all: build deb arch

# Build the container images used for building and packaging
image:
    podman build builder --target base --tag hyperfox-builder
    podman build builder --target package-arch --tag hyperfox-arch

# Build hyperfox dist tarball
build:
    podman image exists hyperfox-builder || just image
    podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-builder bash /src/builder/build-hyperfox.sh

# Package dist tarball as a .deb
deb:
    podman image exists hyperfox-builder || just image
    podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-builder bash /src/builder/build-deb.sh

# Package dist tarball as an alpm pkg
arch:
    podman image exists hyperfox-arch || just image
    podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-arch bash /src/builder/build-pkg.sh

# Delete sources and build artifacts
clean:
    make veryclean
    rm -rf librewolf-* firefox-* hyperfox-* out/
