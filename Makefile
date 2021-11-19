.PHONY : all help clean veryclean check init

version_file=./version
version:=$(shell cat $(version_file))

include assets/Makefile.includes

help :
	@echo "use: make [all] [clean] [veryclean] [check] [source] [init]"
	@echo ""
	@echo "  all         - make librewolf tarball ${version} in source/ folder."
	@echo "  check       - check if there is a new version of Firefox."
	@echo ""
	@echo "  clean       - clean everything except the upstream firefox tarball."
	@echo "  veryclean   - clean everything and the firefox tarball."
	@echo ""
	@echo "  init        - set up local build environment, takes a long time."

clean :
	make -C source clean

veryclean : # deliberately not depending on 'clean' in this case.
	make -C source veryclean


#
# The 'all' target builds everything while trying to minimize
# disk space.
#

all :
	make -C source all

#
# Keeping ./version up to date.
#

check :
	@python3 assets/update-version.py


#
# init: run bootstrap on local machine
#

init :
	wget -q "https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py"
	python3 bootstrap.py --no-interactive --application-choice=browser
	rm -rf bootstrap.py mozilla-unified
