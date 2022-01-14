.PHONY : all help clean veryclean librewolf-patches check librewolf

version:=$(shell cat ./version)
release:=$(shell cat ./release)

## simplistic archive format selection

#archive_create=tar cfJ
#ext=.tar.xz
archive_create=tar cfz
ext=.tar.gz
#archive_create=zip -r9
#ext=.zip


help : README.md

	@echo "use: $(MAKE) [all] [check] [clean] [veryclean] [build] [package] [run]"
	@echo ""
	@echo "  all         - Make LibreWolf source archive ${version}-${release}."
	@echo "  check       - Check if there is a new version of Firefox."
	@echo ""
	@echo "  clean       - Clean everything except the upstream firefox tarball."
	@echo "  veryclean   - Clean everything and the firefox tarball."
	@echo ""
	@echo "  build       - Make LibreWolf source archive and then build it."
	@echo "  package     - Make LibreWolf source archive, then build and package it."
	@echo "  run         - Make LibreWolf source archive, then build and run it."
	@echo ""


check : README.md
	@python3 scripts/update-version.py
	@echo "Current release:" $$(cat ./release)
	@$(MAKE) --no-print-directory -q README.md


include upstream.mk


all : librewolf-$(version)-$(release).source$(ext) README.md


clean :
	rm -rf *~ firefox-$(version) librewolf-$(version) librewolf-$(version)-$(release).source$(ext)

veryclean : clean
	$(MAKE) clean_upstream_file
	rm -rf librewolf-$(version)

librewolf-$(version)-$(release).source$(ext) : $(upstream_filename) ./version ./release scripts/librewolf-patches.py assets/mozconfig assets/patches.txt README.md
	$(MAKE) clean_upstream_dir
	rm -rf librewolf-$(version)
	$(MAKE) create_lw_from_upstream_dir
	python3 scripts/librewolf-patches.py $(version)
	rm -f librewolf-$(version)-$(release).source$(ext)
	$(archive_create) librewolf-$(version)-$(release).source$(ext) librewolf-$(version)
	rm -rf librewolf-$(version)

librewolf-$(version) : librewolf-$(version)-$(release).source$(ext)
	tar xf librewolf-$(version)-$(release).source$(ext)

build : librewolf-$(version)
	(cd librewolf-$(version) && ./mach build)

package : build
	(cd librewolf-$(version) && ./mach package)

run : build
	(cd librewolf-$(version) && ./mach run)

README.md : README.md.in ./version ./release
	@sed "s/__VERSION__/$(version)/g" < $< > tmp
	@sed "s/__RELEASE__/$(release)/g" < tmp > $@
	@rm -f tmp

