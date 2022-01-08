## handle different upstreams, like developer,nightly, or distro specific upstream cases
upstream_filename=bootstrap.py
upstream_dirname=mozilla-unified
$(upstream_filename) :
	wget -q https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py
##
clean_upstream_file :
	rm -f $(upstream_filename)
clean_upstream_dir :
	rm -rf $(upstream_dirname)
create_lw_from_upstream_dir :
	python3 bootstrap.py --no-interactive --application-choice=browser
	mv $(upstream_dirname) librewolf-$(version)

