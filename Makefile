.PHONY : all help clean veryclean check source buildenv build artifacts pub purge init

version_file=./version
version:=$(shell cat $(version_file))

include assets/Makefile.includes

help :
	@echo "use: make [all] [clean] [veryclean] [check]"
	@echo "          [source] [pub] [buildenv] [no-cache] [upload]"
	@echo "          [purge] [prune] [init]"
	@echo ""
	@echo "  all         - do: make source [build-all] artifacts pub"
	@echo "  clean       - clean the biggest folders and intermediate results."
	@echo "  veryclean   - clean everything, including sources and artifacts."
	@echo "  check       - check if there is a new version of Firefox."
	@echo ""
	@echo "  source      - create the source tarball."
	@echo ""
	@echo "  debian10    - build the browser for debian10."
	@echo "  debian11    - build the browser for debian11."
	@echo "  mint20      - build the browser for mint20."
	@echo "  ubuntu20    - build the browser for mint20."
	@echo ""
	@echo "  pub         - copy the final artifact to the pub/librewolf tree."
	@echo ""
	@echo "  buildenv    - 'docker build' the images needed for building."
	@echo "  no-cache    - 'docker build --no-cache' the images."
	@echo "  upload      - upload the images to docker hub."
	@echo ""
	@echo "  purge/prune - remove all docker resources not currently in use."
	@echo "  init        - run bootstrap.py locally."

clean :
	make -C source clean

	make -C build/debian10 clean
	make -C artifacts/debian10 clean

	make -C build/debian11 clean
	make -C artifacts/debian11 clean

	make -C build/mint20 clean
	make -C artifacts/mint20 clean

	make -C build/ubuntu20 clean
	make -C artifacts/ubuntu20 clean

veryclean : # deliberately not depending on 'clean' in this case.
	make -C source veryclean

	make -C buildenv/debian10 veryclean
	make -C build/debian10 veryclean
	make -C artifacts/debian10 veryclean

	make -C buildenv/debian11 veryclean
	make -C build/debian11 veryclean
	make -C artifacts/debian11 veryclean

	make -C buildenv/mint20 veryclean
	make -C build/mint20 veryclean
	make -C artifacts/mint20 veryclean

	make -C buildenv/ubuntu20 veryclean
	make -C build/ubuntu20 veryclean
	make -C artifacts/ubuntu20 veryclean


#
# The 'all' target builds everything while trying to minimize
# disk space.
#

all : source
	make -C source pub

	make debian10
	make -C artifacts/debian10 pub
	make -C build/debian10 veryclean # reclaim disk space

	make debian11
	make -C artifacts/debian11 pub
	make -C build/debian11 veryclean # reclaim disk space

	make mint20
	make -C artifacts/mint20 pub
	make -C build/mint20 veryclean # reclaim disk space

	make ubuntu20
	make -C artifacts/ubuntu20 pub
	make -C build/ubuntu20 veryclean # reclaim disk space

debian10 :
	make -C build/debian10 all # perform ./mach build && ./mach package
	make -C artifacts/debian10 all # make final artifacts

debian11 :
	make -C build/debian11 all # perform ./mach build && ./mach package
	make -C artifacts/debian11 all # make final artifacts

mint20 :
	make -C build/mint20 all # perform ./mach build && ./mach package
	make -C artifacts/mint20 all # make final artifacts

ubuntu20 :
	make -C build/ubuntu20 all # perform ./mach build && ./mach package
	make -C artifacts/ubuntu20 all # make final artifacts


#
# Keeping ./version up to date.
#

check :
	@python3 assets/update-version.py


#
# Making the source tarball
#

source :
	make -C source all


#
# buildenv: Creating build environment and performing the build
#

buildenv :
	make -C buildenv/debian10 build
	make -C buildenv/debian11 build
	make -C buildenv/mint20 build
	make -C buildenv/ubuntu20 build

no-cache :
	make -C buildenv/debian10 no-cache
	make -C buildenv/debian11 no-cache
	make -C buildenv/ubuntu20 no-cache

upload :
	make -C buildenv/debian10 upload
	make -C buildenv/debian11 upload
	make -C buildenv/ubuntu20 upload


#
# pub
#

pub :
	make -C source pub
	make -C artifacts/debian10 pub
	make -C artifacts/debian11 pub
	make -C artifacts/mint20 pub
	make -C artifacts/ubuntu20 pub


#
# zapping all docker state..
#

purge : prune
prune :
	$(docker) system prune --all --force


#
# init: run bootstrap on local machine
#

init :
	wget -q "https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py"
	python3 bootstrap.py --no-interactive --application-choice=browser
	rm -rf bootstrap.py mozilla-unified
