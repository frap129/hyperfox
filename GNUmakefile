#######################
## SaberFox Makefile ##
#######################
#
# This Makefile adds features that aren't attainable
# through the ./mach build tool. Build Directory 
# clobbering, PNGQuant optimizations, and automatic
# build parallelization are the current features.
#

# Define Jobs to use for mach
JOBS="-j $(grep -c ^processor /proc/cpuinfo)"

# Build and package a clean apk
all: clean build package

# Optimize with PNGQuant and package apk
apk:
	cd obj-arm-linux-androideabi/ && find . -name "*.png" -print0 | xargs -0 -P8 -L1 pngquant --ext .png --force --speed 1 -v && ../mach package

# Build app resources with optimal jobs
bacon:
	./mach build $(JOBS)
	
# Build app resources
build:
	./mach build
	
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

.PHONY: all apk bacon build clean clobber package saber
