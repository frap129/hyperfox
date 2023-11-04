.PHONY : bsys6_x86_64_linux_bz2_artifact full_build_stage2

#
# This makefile just uses bsys6 to build the package
# 
# we implicitly fully test that his source builds
# with the latest version of bsys6.
#
# so we also know that our docker images builds
# will succeed if this test succeeds.
#


bsys6_x86_64_linux_bz2_artifact :

	rm -rf bsys6
	git clone "https://codeberg.org/librewolf/bsys6.git"
	(cd bsys6 && ${MAKE} -f ../assets/testing.mk full_build_stage2)
	cp -v bsys6/*.bz2 .
	rm -rf bsys6


full_build_stage2:

	echo "[debug] Starting full_build_stage2"

	echo "VERSION=$$(cat ../version)-$$(cat ../release)" > env.sh
	echo "WORKDIR=$$(pwd)/WORKDIR" >> env.sh
	echo "TARGET=linux" >> env.sh
	echo "ARCH=x86_64" >> env.sh
	echo "SOURCEDIR=$$(pwd)/SOURCEDIR/librewolf-$$(cat ../version)-$$(cat ../release)" >> env.sh
	cat env.sh


	mkdir WORKDIR
	mkdir SOURCEDIR
	(cd SOURCEDIR && tar xf ../../librewolf*.tar.gz)


	ARCH=x86_64 ./bsys6 prepare
	ARCH=x86_64 ./bsys6 package

	@echo "[debug] Done full_build_stage2"
