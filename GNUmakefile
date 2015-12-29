#######################
## SaberFox Makefile ##
#######################
#
# This Makefile adds features that aren't attainable
# through the ./mach build tool. True build directory 
# clobbering, PNGQuant optimizations, and automatic
# build parallelization are the current features.
#

# Define Jobs to use for mach
JOBS="-j$(shell grep -c ^processor /proc/cpuinfo)"

# Build and package a clean apk
all: clean build package

# Optimize with PNGQuant and package apk
apk:
	@echo "Optimizing images and packaging apk..."
	@cd obj-arm-linux-androideabi/ && find . -name "*.png" -print0 | xargs -0 -P8 -L1 pngquant --ext .png --force --speed 1 && cd .. && ./mach package

# Build app resources with optimal jobs
bacon:
	@echo "Building SaberFox resources..."
	@./mach build $(JOBS)
	
# Build app resources
build:
	@echo "Building SaberFox resources..."
	@./mach build
	
# Clean object directory
clean:
	@echo "Cleaning object directory..."
	@./mach clobber

# Delete object directory
clobber: 
	@echo "Clobbering object directory..."
	@rm -rf obj-arm-linux-androideabi
	
# Package apk
package:
	@echo "Packaging apk..."
	@./mach package

# Optimal build combo
saber: clobber bacon apk

.PHONY: all apk bacon build clean clobber package saber
