## handle different upstreams, like developer,nightly, or distro specific upstream cases
upstream_filename=firefox-$(version).source.tar.xz
upstream_dirname=firefox-$(version)
$(upstream_filename) :
	wget -q https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz
##
