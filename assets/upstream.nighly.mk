## handle different upstreams, like developer,nightly, or distro specific upstream cases
upstream_filename=mozilla-unified
upstream_dirname=mozilla-unified
$(upstream_filename) :
	hg clone https://hg.mozilla.org/mozilla-unified
	(cd mozilla-unified && hg update)
##
clean_upstream_file :
clean_upstream_dir :
create_lw_from_upstream_dir :
	(cd mozilla-unified && hg pull)
	(cd mozilla-unified && hg update)
	cp -r $(upstream_dirname) librewolf-$(version)

