/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

"use strict";

// Services = object with smart getters for common XPCOM services
var { Services } = ChromeUtils.import("resource://gre/modules/Services.jsm");
var { AppConstants } = ChromeUtils.import(
  "resource://gre/modules/AppConstants.jsm"
);

async function init(aEvent) {
  if (aEvent.target != document) {
    return;
  }

  var distroId = Services.prefs.getCharPref("distribution.id", "");
  if (distroId) {
    var distroAbout = Services.prefs.getStringPref("distribution.about", "");
    // If there is about text, we always show it.
    if (distroAbout) {
      var distroField = document.getElementById("distribution");
      distroField.value = distroAbout;
      distroField.style.display = "block";
    }
    // If it's not a mozilla distribution, show the rest,
    // unless about text exists, then we always show.
    if (!distroId.startsWith("mozilla-") || distroAbout) {
      var distroVersion = Services.prefs.getCharPref(
        "distribution.version",
        ""
      );
      if (distroVersion) {
        distroId += " - " + distroVersion;
      }

      var distroIdField = document.getElementById("distributionId");
      distroIdField.value = distroId;
      distroIdField.style.display = "block";
    }
  }

  // Display current version number
  let versionField = document.getElementById("versionNumber");
  versionField.innerHTML = AppConstants.MOZ_APP_VERSION_DISPLAY;

  // If pref "librewolf.aboutMenu.checkVersion" is set to true,
  // check for new version with the link given in "librewolf.aboutMenu.versionCheckGitlabUrl"
  if (Services.prefs.getBoolPref("librewolf.aboutMenu.checkVersion", false)) {
    let versionDiv = document.getElementById("version");
    const loader = document.createElement("div");
    loader.classList.add("loader");
    versionDiv.appendChild(loader);

    function isNewerVersion(newVersionString, oldVersionString) {
      let [oldVersion, oldRelease] = oldVersionString.replace(/^v/, "").split("-");
      let [newVersion, newRelease] = newVersionString.replace(/^v/, "").split("-");
      console.log(oldVersionString, newVersionString)
      if (oldVersion && newVersion) {
        if (!oldRelease) oldRelease = "0";
        if (!newRelease) newRelease = "0";

        // Check version
        for (let i = 0; i < newVersion.split(".").length; i++) {
          if (Number(newVersion.split(".")[i]) > Number(oldVersion?.split(".")[i] || "0")) return true;
        }

        // Check release
        if (Number(newRelease) > Number(oldRelease)) return true;
      }
      return false;
    }

    fetch(
      Services.prefs.getStringPref(
        "librewolf.aboutMenu.versionCheckGitlabUrl",
        "https://gitlab.com/api/v4/projects/32320088/releases"
      )
    )
      .then(response => response.json())
      .then(data => {
        if (data.length > 0) {
          const latestVersion = data[0].tag_name;
          if (isNewerVersion(latestVersion, AppConstants.MOZ_APP_VERSION_DISPLAY)) {
            const updateNotice = document.createElement("a");
            updateNotice.classList.add("text-link");
            updateNotice.href = data[0]._links.self;
            updateNotice.onclick = () => window.openWebLinkIn(data[0]._links.self, "tab")
            updateNotice.innerText = "(Update available)";
            versionDiv.appendChild(updateNotice);
          } else {
            const upToDateNotice = document.createElement("div")
            upToDateNotice.innerText = "(Up to date)";
            versionDiv.appendChild(upToDateNotice);
          }
        }
        loader.remove();
      })
  }

  const logos = [
    {
      creator: "/u/NO8X71",
      url: "https://old.reddit.com/r/LibreWolf/comments/u91scw/revised_alternate_icons_with_a_night_version/"
    },
    {
      creator: "/u/Lythrox",
      url: "https://old.reddit.com/r/LibreWolf/comments/ub65m6/librewolf_netscape_tribute/"
    },
    {
      creator: "/u/rere_dnaw",
      url: "https://old.reddit.com/r/LibreWolf/comments/rh28rq/new_logo_ideas/"
    },
    {
      creator: "/u/chunkyhairball",
      url: "https://old.reddit.com/r/LibreWolf/comments/qk5jiv/i_like_cute_icons_so_ima_leave_this_here/"
    },
    {
      creator: "/u/diiscotheque",
      url: "https://old.reddit.com/r/LibreWolf/comments/tb4i52/icon_update_2/"
    },
    {
      creator: "/u/Huginstog",
      url: "https://old.reddit.com/r/LibreWolf/comments/u5yi3d/fluffier_cuddlier_but_still_free_wild/"
    },
    {
      creator: "/u/diiscotheque",
      url: "https://old.reddit.com/r/LibreWolf/comments/t9c84n/icon_update/"
    },
  ]

  let i = Math.floor(Math.random() * 6);

  function newLogo() {
    i += 1;
    i = i % logos.length;
    const a = i % 2 === 0 ? "A" : "B";
    const b = i % 2 === 1 ? "A" : "B";
    document.getElementById("logo" + a).style.backgroundImage = `url("chrome://browser/content/aboutLogos/${i}.png")`;
    document.getElementById("logo" + a).style.opacity = 1;
    document.getElementById("logo" + b).style.opacity = 0;
    document.getElementById("logoCreator" + a).innerHTML = logos[i].creator
    document.getElementById("logoCreator" + a).href = logos[i].url;
    document.getElementById("logoCreator" + a).style.opacity = 1;
    document.getElementById("logoCreator" + b).style.opacity = 0;
    document.getElementById("logoCreator" + a).style.pointerEvents = "all";
    document.getElementById("logoCreator" + b).style.pointerEvents = "none";
  }

  newLogo();
  setInterval(newLogo, 7000);

  window.sizeToContent();

  if (AppConstants.platform == "macosx") {
    window.moveTo(
      screen.availWidth / 2 - window.outerWidth / 2,
      screen.availHeight / 5
    );
  }
}
 