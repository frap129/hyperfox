build:
   podman build builder --target builder --tag hyperfox-builder
   podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-builder

deb:
   podman build builder --target package-deb --tag hyperfox-deb
   podman run --rm --userns=keep-id --group-add=keep-groups -v ${PWD}:/src -it hyperfox-deb 

clean:
   make veryclean
   rm -rf librewolf-* firefox-* hyperfox-*
