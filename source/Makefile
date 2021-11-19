.PHONY : all help clean veryclean fetch extract librewolf-patches pub
version_file=../version
version:=$(shell cat $(version_file))

all : librewolf-$(version).source.tar.gz

help :
	@echo "Use: make [all] [clean] [veryclean] [pub]"
	@echo ""
	@echo "  all           - build librewolf-$(version).source.tar.gz"
	@echo "  clean         - remove all source trees and other cruft"
	@echo "  veryclean     - same as clean, but also remove source archives"
	@echo "  pub           - copy Libewolf source to pub folder"

clean :
	rm -rf *~ firefox-$(version) librewolf-$(version) librewolf-$(version).source.tar.gz work

veryclean : clean
	rm -f firefox-$(version).source.tar.xz

fetch : 
	rm -f firefox-$(version).source.tar.xz
	make firefox-$(version).source.tar.xz

firefox-$(version).source.tar.xz : 
	wget -q https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz

# we take this extra step seperatly because it's so important.
librewolf-patches :
	rm -rf work && mkdir -p work
	python3 ../assets/librewolf-patches.py $(version)
	rm -rf work

librewolf-$(version).source.tar.gz : firefox-$(version).source.tar.xz $(version_file) ../assets/librewolf-patches.py ../assets/build-librewolf.py ../assets/mozconfig ../assets/patches-$(version).txt
	rm -rf firefox-$(version) librewolf-$(version)
	tar xf firefox-$(version).source.tar.xz
	mv firefox-$(version) librewolf-$(version)
	make librewolf-patches
	rm -f librewolf-$(version).source.tar.gz
	tar cfz librewolf-$(version).source.tar.gz librewolf-$(version)
	rm -rf librewolf-$(version)

pub : librewolf-$(version).source.tar.gz
	cp -v $< ../pub/librewolf/librewolf-$(version)

