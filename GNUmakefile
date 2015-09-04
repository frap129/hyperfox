# This Makefile is used as a shim to aid people with muscle memory
# so that they can type "make".
#
# This file and all of its targets should not be used by anything important.

all: build

build:
	./mach build -j8

clean:
	./mach clobber

package:
	cd obj-arm-linux-androideabi/ && find . -name "*.png" -print0 | xargs -0 -P8 -L1 pngquant --ext .png --force --speed 1 -v && $(topsrcdir)/mach package

.PHONY: all build clean package
