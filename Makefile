.PHONY : help check all clean veryclean bootstrap build package run update

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
	@echo "  update      - Update the git submodules and README.md."
	@echo ""
	@echo "  clean       - Clean everything except the upstream firefox tarball."
	@echo "  veryclean   - Clean everything including the firefox tarball."
	@echo ""
	@echo "  bootstrap   - Bootstrap the build environment."
	@echo ""
	@echo "  build       - Build LibreWolf (requires bootstraped build environment)."
	@echo "  package     - Package LibreWolf (requires build)."
	@echo "  run         - Run LibreWolf (requires build)."
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


all : $(lw_source_tarball)


clean :
	rm -rf *~ $(ff_source_dir) $(lw_source_dir) $(lw_source_tarball)

veryclean : clean
	rm -rf $(ff_source_tarball)

#
# The actual build stuff
#


$(ff_source_tarball) :
	wget -q "https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz" -O $(ff_source_tarball)

$(lw_source_dir) : $(ff_source_tarball) ./version ./release scripts/librewolf-patches.py assets/mozconfig assets/patches.txt
	rm -rf $(ff_source_dir) $(lw_source_dir)
	tar xf $(ff_source_tarball)
	mv $(ff_source_dir) $(lw_source_dir)
	python3 scripts/librewolf-patches.py $(version) $(release)

$(lw_source_tarball) : $(lw_source_dir)
	rm -f $(lw_source_tarball)
	$(archive_create) $(lw_source_tarball) $(lw_source_dir)

debs=python3 python3-dev python3-pip
rpms=python3 python3-devel
bootstrap : $(lw_source_dir)
	(sudo apt -y install $(debs); true)
	(sudo rpm -y install $(rpms); true)
	(cd $(lw_source_dir) && MOZBUILD_STATE_PATH=$$HOME/.mozbuild ./mach --no-interactive bootstrap --application-choice=browser)

build : $(lw_source_dir)
	(cd $(lw_source_dir) && ./mach build)

package :
	(cd $(lw_source_dir) && ./mach package)
	cp -v $(lw_source_dir)/obj-*/dist/librewolf-$(version)-$(release).en-US.*.tar.bz2 .

run :
	(cd $(lw_source_dir) && ./mach run)
