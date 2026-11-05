.POSIX:
.PHONY: help version release bootstrap build run package clean release_tarball

VERSION = 159.0.1
RELEASE = 1

TARGET=

FF_BASE_URL = https://archive.mozilla.org/pub/firefox
FF_CHANNEL = releases
FF_BUILD = build1
FF_BETA_SUFFIX =

ff_source_dir = firefox-$(VERSION)
ff_source_tarball = firefox-$(VERSION)$(FF_BETA_SUFFIX).source.tar.xz

lw_source_dir = librewolf-$(VERSION)-$(RELEASE)
lw_source_tarball = librewolf-$(VERSION)-$(RELEASE).source.tar.gz

help:
	@echo "idk :)"

version:
	@printf '%s\n' '$(VERSION)'

release:
	@printf '%s\n' '$(RELEASE)'

$(ff_source_tarball):
	gpg --import assets/MOZILLA_PUBKEY.asc
	ff_source_url="$(FF_BASE_URL)/releases/$(VERSION)/source/$(ff_source_tarball)"; \
	if [ "$(FF_CHANNEL)" = "candidates" ]; then \
		ff_source_url="$(FF_BASE_URL)/candidates/$(VERSION)-candidates/$(FF_BUILD)/source/$(ff_source_tarball)"; \
	elif [ "$(FF_CHANNEL)" = "beta" ]; then \
		ff_source_url="$(FF_BASE_URL)/candidates/$(VERSION)$(FF_BETA_SUFFIX)-candidates/$(FF_BUILD)/source/$(ff_source_tarball)"; \
	fi; \
	curl -qfA "" --no-sessionid --proto =https --tlsv1.2 \
		"$$ff_source_url" -o $(ff_source_tarball) \
		"$$ff_source_url.asc" -o $(ff_source_tarball).asc; \
	gpg --verify $(ff_source_tarball).asc $(ff_source_tarball)

$(ff_source_dir): $(ff_source_tarball)
	tar -xf $(ff_source_tarball)

$(lw_source_dir): $(ff_source_dir) scripts/patch.sh
	cp -R $(ff_source_dir) $(lw_source_dir)
	(cd $(lw_source_dir) && ../scripts/patch.sh $(VERSION) $(RELEASE))

$(lw_source_tarball): $(lw_source_dir)
	tar cf librewolf-$(VERSION)-$(RELEASE).source.tar $(lw_source_dir)
	pigz -f -9 librewolf-$(VERSION)-$(RELEASE).source.tar
	sha256sum $(lw_source_tarball) > $(lw_source_tarball).sha256sum
	sha256sum -c $(lw_source_tarball).sha256sum
	sha512sum $(lw_source_tarball) > $(lw_source_tarball).sha512sum
	sha512sum -c $(lw_source_tarball).sha512sum
	if [ -n "$${SIGNING_KEY}" ]; then printf '%s\n' "$${SIGNING_KEY}" | gpg --import && gpg --detach-sign $(lw_source_tarball); fi

bootstrap: $(lw_source_dir)
	(cd $(lw_source_dir) && ./mach --no-interactive bootstrap --application-choice=browser)

build: $(lw_source_dir)
	if [ -n "$(TARGET)" ]; then \
		echo "ac_add_options --target=$(TARGET)" >> $(lw_source_dir)/mozconfig; \
	fi
	(cd $(lw_source_dir) && ./mach build)

run: $(lw_source_dir)
	(cd $(lw_source_dir) && ./mach run)

package: $(lw_source_dir)
	(cd $(lw_source_dir) && cat browser/locales/shipped-locales | xargs ./mach package-multi-locale --locales)
	cp -v $(lw_source_dir)/obj-*/dist/librewolf-$(VERSION)-$(RELEASE).en-US.*.tar.xz .

tarball: $(lw_source_tarball)

clean:
	rm -rf $(ff_source_tarball) $(ff_source_tarball).asc $(ff_source_dir) $(lw_source_dir) $(lw_source_tarball) $(lw_source_tarball).sha256sum $(lw_source_tarball).sha512sum $(lw_source_tarball).sig
