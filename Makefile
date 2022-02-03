.PHONY : help check all clean veryclean bootstrap build package run update

version:=$(shell cat ./version)
release:=$(shell cat ./release)

## simplistic archive format selection

#archive_create=tar cfJ
#ext=.tar.xz
archive_create=tar cfz
ext=.tar.gz

upstream_filename=firefox-$(version).source.tar.xz
upstream_dirname=firefox-$(version)


help :

	@echo "use: $(MAKE) [all] [check] [clean] [veryclean] [build] [package] [run]"
	@echo ""
	@echo "  all         - Make LibreWolf source archive ${version}-${release}."
	@echo "  check       - Check if there is a new version of Firefox."
	@echo "  update      - Update the git submodules and README.md."
	@echo ""
	@echo "  clean       - Clean everything except the upstream firefox tarball."
	@echo "  veryclean   - Clean everything including the firefox tarball."
	@echo ""
	@echo "  bootstrap   - Make librewolf source archive, and bootstrap the build system."
	@echo ""
	@echo "  build       - After a bootstrap, build it."
	@echo "  package     - After a build, package it."
	@echo "  run         - After a build, run it."
	@echo ""


check :
	python3 scripts/update-version.py
	@echo "Current release:" $$(cat ./release)


update : README.md
	git submodule update --recursive --remote

README.md : README.md.in ./version ./release
	@sed "s/__VERSION__/$(version)/g" < $< > tmp
	@sed "s/__RELEASE__/$(release)/g" < tmp > $@
	@rm -f tmp


all : librewolf-$(version)-$(release).source$(ext)


clean :
	rm -rf *~ firefox-$(version) librewolf-$(version) librewolf-$(version)-$(release).source$(ext)

veryclean : clean
	rm -f $(upstream_filename)

#
# The actual build stuff
#


$(upstream_filename) :
	wget -q "https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz"

librewolf-$(version)-$(release).source$(ext) : $(upstream_filename) ./version ./release scripts/librewolf-patches.py assets/mozconfig assets/patches.txt
	rm -rf $(upstream_dirname)
	rm -rf librewolf-$(version)
	tar xf $(upstream_filename)
	mv  $(upstream_dirname) librewolf-$(version)
	python3 scripts/librewolf-patches.py $(version) $(release)
	rm -f librewolf-$(version)-$(release).source$(ext)
	$(archive_create) librewolf-$(version)-$(release).source$(ext) librewolf-$(version)
	touch librewolf-$(version)

librewolf-$(version) : librewolf-$(version)-$(release).source$(ext)
	tar xf librewolf-$(version)-$(release).source$(ext)

debs=python3 python3-dev python3-pip
rpms=python3 python3-devel
bootstrap : librewolf-$(version)
	(sudo apt -y install $(debs); true)
	(sudo rpm -y install $(rpms); true)
	(cd librewolf-$(version) && MOZBUILD_STATE_PATH=$$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser)

build :
	(cd librewolf-$(version) && ./mach build)

package :
	(cd librewolf-$(version) && ./mach package)

run :
	(cd librewolf-$(version) && ./mach run)

