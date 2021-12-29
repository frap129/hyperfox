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

	@echo "use: make [all] [check] [clean] [veryclean]"
	@echo ""
	@echo "  all         - Make librewolf source archive ${version}-${release}."
	@echo "  check       - Check if there is a new version of Firefox."
	@echo ""
	@echo "  clean       - Clean everything except the upstream firefox tarball."
	@echo "  veryclean   - Clean everything and the firefox tarball."
	@echo "  librewolf   - like 'make all' but after that extract and build it."
	@echo ""


check : README.md
	@python3 scripts/update-version.py
	@echo "Current release:" $$(cat ./release)
	@make --no-print-directory -q README.md


all : librewolf-$(version)-$(release).source$(ext) README.md


clean :
	rm -rf *~ firefox-$(version) librewolf-$(version) librewolf-$(version)-$(release).source$(ext)


veryclean : clean
	rm -f firefox-$(version).source.tar.xz
	rm -rf librewolf-$(version)


firefox-$(version).source.tar.xz :
	wget -q https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz


librewolf-$(version)-$(release).source$(ext) : firefox-$(version).source.tar.xz ./version ./release scripts/librewolf-patches.py assets/mozconfig assets/patches.txt
	rm -rf firefox-$(version) librewolf-$(version)
	tar xf firefox-$(version).source.tar.xz
	mv firefox-$(version) librewolf-$(version)
	python3 scripts/librewolf-patches.py $(version)
	rm -f librewolf-$(version)-$(release).source$(ext)
	$(archive_create) librewolf-$(version)-$(release).source$(ext) librewolf-$(version)
	rm -rf librewolf-$(version)

librewolf-$(version) : librewolf-$(version)-$(release).source$(ext)
	tar xf librewolf-$(version)-$(release).source$(ext)

librewolf : librewolf-$(version)
	(cd librewolf-$(version) && ./mach build && ./mach package)

README.md : README.md.in ./version ./release
	@sed "s/__VERSION__/$(version)/g" < $< > tmp
	@sed "s/__RELEASE__/$(release)/g" < tmp > $@
	@rm -f tmp

