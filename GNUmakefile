# This Makefile is used as a shim to aid people with muscle memory
# so that they can type "make".
#
# This file and all of its targets should not be used by anything important.

# Define Jobs to use for mach
JOBS="-j $(grep -c ^processor /proc/cpuinfo)"

# Build and package a clean apk
all: clean build package

# Optimize with PNGQuant and package apk
apk:
	cd obj-arm-linux-androideabi/ && find . -name "*.png" -print0 | xargs -0 -P8 -L1 pngquant --ext .png --force --speed 1 -v && ../mach package

# Build app resources
build:
	./mach build

# Build app resources with optimal jobs
bacon:
	./mach build $(JOBS)
	
# Clean object directory
clean:
	./mach clobber

# Delete object directory
clobber: 
	rm -rf obj-arm-linux-androideabi
	
# Package apk
package:
	./mach package

# Optimal build combo
saber: clobber bacon apk

.PHONY: all apk build bacon clean clobber package saber
