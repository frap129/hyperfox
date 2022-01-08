## handle different upstreams, like developer,nightly, or distro specific upstream cases
upstream_filename=firefox-$(version).source.tar.xz
upstream_dirname=firefox-$(version)
$(upstream_filename) :
	wget -q https://archive.mozilla.org/pub/firefox/releases/$(version)/source/firefox-$(version).source.tar.xz
##
clean_upstream_file :
	rm -f $(upstream_filename)
clean_upstream_dir :
	rm -rf $(upstream_dirname)
create_lw_from_upstream_dir :
	tar xf $(upstream_filename)
	mv  $(upstream_dirname) librewolf-$(version)

