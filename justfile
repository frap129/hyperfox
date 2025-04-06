# Build hyperfox and all packages
all:build deb arch

# Build hyperfox dist tarball
build:
   podman build builder --target builder --tag hyperfox-builder
   podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-builder

# Package dist tarball as a .deb
deb:
   podman build builder --target package-deb --tag hyperfox-deb
   podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-deb 

# Package dist tarball as an alpm pkg
arch:
   podman build builder --target package-arch --tag hyperfox-arch
   podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-arch

# Delete sources and build artifacts
clean:
   make veryclean
   rm -rf librewolf-* firefox-* hyperfox-* out/
