docker_targets=docker-build-image docker-run-build-job docker-remove-image

.PHONY : help check all clean veryclean dir bootstrap fetch build package run update setup-wasi check-patchfail check-fuzz fixfuzz $(docker_targets)

version:=$(shell cat ./version)
release:=$(shell cat ./release)

## simplistic archive format selection

#archive_create=tar cfJ
#ext=.tar.xz
archive_create:=tar cfz
ext:=.tar.gz

ff_source_dir:=firefox-$(version)
ff_source_tarball:=firefox-$(version).source.tar.xz

lw_source_dir:=librewolf-$(version)-$(release)
lw_source_tarball:=librewolf-$(version)-$(release).source$(ext)

help :

	@echo "use: $(MAKE) [all] [check] [clean] [veryclean] [bootstrap] [build] [package] [run]"
	@echo ""
	@echo "  all         - Make LibreWolf source archive ${version}-${release}."
	@echo "  check       - Check if there is a new version of Firefox."
	@echo "  update      - Update the git submodules."
	@echo ""
	@echo "  clean       - Clean everything except the upstream firefox tarball."
	@echo "  veryclean   - Clean everything including the firefox tarball."
	@echo ""
	@echo "  bootstrap   - Bootstrap the build environment."
	@echo "  setup-wasi  - Setup WASM sandbox libraries (required on Linux)."
	@echo ""
	@echo "  fetch       - fetch Firefox source archive."
	@echo "  dir         - extract Firefox and apply the patches, creating a"
	@echo "                ready to build librewolf folder."
	@echo "  build       - Build LibreWolf (requires bootstrapped build environment)."
	@echo "  package     - Package LibreWolf (requires build)."
	@echo "  run         - Run LibreWolf (requires build)."
	@echo ""
	@echo "  check-patchfail - check patches for errors."
	@echo "  check-fuzz      - check patches for fuzz."
	@echo "  fixfuz          - fix the fuzz."
	@echo ""
	@echo "docker:" $(docker_targets)

check :
	python3 scripts/update-version.py
	cut -f1 version > version.tmp
	mv -vf version.tmp version
	@echo ""
	@echo "Firefox version   : " $$(cat version)
	@echo "LibreWolf release : " $$(cat release)
	@echo ""


update :
	git submodule update --recursive --remote


all : $(lw_source_tarball)


clean :
	rm -rf *~ public_key.asc $(ff_source_dir) $(lw_source_dir) $(lw_source_tarball) $(lw_source_tarball).sha256sum firefox-$(version) patchfail.out patchfail-fuzz.out

veryclean : clean
	rm -f $(ff_source_tarball) $(ff_source_tarball).asc



#
# The actual build stuff
#

fetch : $(ff_source_tarball)

$(ff_source_tarball) :
	wget -qO public_key.asc "https://keys.openpgp.org/vks/v1/by-fingerprint/14F26682D0916CDD81E37B6D61B7B526D98F0353"
	gpg --import public_key.asc
	rm -f public_key.asc
	wget -q "https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz.asc" -O $(ff_source_tarball).asc
	wget -q "https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz" -O $(ff_source_tarball)
	gpg --verify $(ff_source_tarball).asc $(ff_source_tarball)


$(lw_source_dir) : $(ff_source_tarball) ./version ./release scripts/librewolf-patches.py assets/mozconfig assets/patches.txt
	rm -rf $(ff_source_dir) $(lw_source_dir)
	tar xf $(ff_source_tarball)
	mv $(ff_source_dir) $(lw_source_dir)
	python3 scripts/librewolf-patches.py $(version) $(release)

$(lw_source_tarball) : $(lw_source_dir)
	rm -f $(lw_source_tarball)
	$(archive_create) $(lw_source_tarball) $(lw_source_dir)
	touch $(lw_source_dir)
	sha256sum $(lw_source_tarball) > $(lw_source_tarball).sha256sum
	cat $(lw_source_tarball).sha256sum
	[ "$(SIGNING_KEY)" != "" ] && cp -v $(SIGNING_KEY) pk.asc ; true
	if [ -f pk.asc ]; then gpg --import pk.asc; gpg --detach-sign $(lw_source_tarball) && ls -lh $(lw_source_tarball).sig; fi


debs=python3 python3-dev python3-pip
rpms=python3 python3-devel
bootstrap : $(lw_source_dir)
	(sudo apt -y install $(debs); true)
	(sudo rpm -y install $(rpms); true)
	(cd $(lw_source_dir) && MOZBUILD_STATE_PATH=$$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser)

setup-wasi :
	./scripts/setup-wasi-linux.sh


dir : $(lw_source_dir)

build : $(lw_source_dir)
	(cd $(lw_source_dir) && ./mach build)

package :
	(cd $(lw_source_dir) && cat browser/locales/shipped-locales | xargs ./mach package-multi-locale --locales)
	cp -v $(lw_source_dir)/obj-*/dist/librewolf-$(version)-$(release).en-US.*.tar.bz2 .

run :
	(cd $(lw_source_dir) && ./mach run)

check-patchfail:
	sh -c "./scripts/check-patchfail.sh" > patchfail.out
check-fuzz:
	-sh -c "./scripts/check-patchfail.sh --fuzz=0" > patchfail-fuzz.out
fixfuzz :
	sh -c "./scripts/fuzzfail.sh"






#
# docker
#


build_image=librewolf-build-image

docker-build-image :
	docker build --no-cache -t $(build_image) - < assets/Dockerfile

docker-run-build-job :
	docker run -v $$(pwd):/output --rm $(build_image) sh -c "git pull && make fetch && make build package && cp -v ./*.bz2 /output"

docker-remove-image :
	docker rmi $(build_image)

setup-debian :
	apt-get -y install mercurial python3 python3-dev python3-pip curl wget dpkg-sig  libssl-dev zstd libxml2-dev

setup-fedora :
	dnf -y install python3 curl wget zstd python3-devel python3-pip mercurial openssl-devel libxml2-devel

