.PHONY : all help clean veryclean librewolf-patches check librewolf


version_file=./version
version:=$(shell cat $(version_file))


## simplistic archive format selection
archive_create=tar cfJ
ext=.tar.xz
archive_create=tar cfz
ext=.tar.gz
#archive_create=zip -r9
#ext=.zip


help :

	@echo "use: make [all] [check] [clean] [veryclean]"
	@echo ""
	@echo "  all         - Make librewolf source archive ${version}."
	@echo "  check       - Check if there is a new version of Firefox."
	@echo ""
	@echo "  clean       - Clean everything except the upstream firefox tarball."
	@echo "  veryclean   - Clean everything and the firefox tarball."
	@echo "  librewolf   - like 'make all' but after that extract and build it."


check :
	@python3 scripts/update-version.py


all : librewolf-$(version).source$(ext)


clean :
	rm -rf *~ firefox-$(version) librewolf-$(version) librewolf-$(version).source$(ext) work


veryclean : clean
	rm -f firefox-$(version).source.tar.xz
	rm -rf librewolf-$(version)


firefox-$(version).source.tar.xz :
	wget -q https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz


# we take this extra step seperatly because it's so important.
librewolf-patches :
	rm -rf work && mkdir work
	python3 scripts/librewolf-patches.py $(version)
	rm -rf work


librewolf-$(version).source$(ext) : firefox-$(version).source.tar.xz $(version_file) scripts/librewolf-patches.py scripts/build-librewolf.py assets/mozconfig assets/patches.txt
	rm -rf firefox-$(version) librewolf-$(version)
	tar xf firefox-$(version).source.tar.xz
	mv firefox-$(version) librewolf-$(version)

	make librewolf-patches

	rm -f librewolf-$(version).source$(ext)
	$(archive_create) librewolf-$(version).source$(ext) librewolf-$(version)
	rm -rf librewolf-$(version)

librewolf-$(version) : librewolf-$(version).source$(ext)
	tar xf librewolf-$(version).source$(ext)

librewolf : librewolf-$(version)
	(cd librewolf-$(version) && ./mach build && ./mach package)
