### overview:
* This folder replaces the original big pref-pane.patch, the original patch is moved into the `patches/removed-patches` folder.
* This new solution should make it much easier for everyone to edit the librewolf preferences.

### new files, these contain all the logic for the pref-pane:

* category-librewolf.svg -> browser/themes/shared/preferences/category-librewolf.svg
* librewolf.css -> browser/themes/shared/preferences/librewolf.css
* librewolf.inc.xhtml -> browser/components/preferences/librewolf.inc.xhtml
* librewolf.js -> browser/components/preferences/librewolf.js

### appending these string values to the original preferences.ftl:

* preferences.ftl -- append to --> browser/locales/en-US/browser/preferences/preferences.ftl
