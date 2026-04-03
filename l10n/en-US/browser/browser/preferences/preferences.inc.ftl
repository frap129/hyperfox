## LibreWolf preferences

# Sidebar
pane-librewolf-title = LibreWolf
category-librewolf =
    .tooltiptext = about:config changes, logically grouped and easily accessible
# Main content
librewolf-header = LibreWolf Preferences
librewolf-warning-title = Heads up!
librewolf-warning-description = We carefully choose default settings to focus on privacy and security. When changing these settings, read the descriptions to understand the implications of those changes.
# Page Layout
librewolf-general-heading2 =
    .label = Browser Behavior
librewolf-extension-update-checkbox2 =
    .label = Update add-ons automatically
    .description = Keep extensions up to date without manual intervention. A good choice for your security.
librewolf-sync-checkbox2 =
    .label = Enable Firefox Sync
    .description = Sync your data with other browsers. Requires restart.
librewolf-autocopy-checkbox2 =
    .label = Enable middle click paste
    .description = Select some text to copy it, then paste it with a middle-mouse click.
librewolf-styling-checkbox2 =
    .label = Allow userChrome.css customization
    .description = Enable this if you want to customize the UI with a manually loaded theme.
librewolf-network-heading2 =
    .label = Networking
librewolf-ipv6-checkbox2 =
    .label = Enable IPv6
    .description = Allow { -brand-short-name } to connect using IPv6.
librewolf-privacy-heading2 =
    .label = Privacy
librewolf-xorigin-ref-checkbox2 =
    .label = Limit cross-origin referrers
    .description = Send a referrer only on same-origin.
librewolf-broken-heading2 =
    .label = Fingerprinting
librewolf-webgl-checkbox2 =
    .label = Always allow WebGL
    .description = This will always allow WebGL without requiring permission.
librewolf-webgl-prompt-checkbox2 =
    .label = Hide the WebGL per-site popup
    .description = This hides the popup that appears when a site tries to create a WebGL context. You can still manually bring up the prompt by clicking the icon in the searchbar.
librewolf-rfp-checkbox2 =
    .label = Enable ResistFingerprinting
    .description = Enables all available fingerprint mitigations, but can cause some websites to function improperly.
librewolf-letterboxing-checkbox2 =
    .label = Enable letterboxing
    .description = Letterboxing applies margins around your windows, in order to return a limited set of rounded resolutions.
librewolf-security-heading2 =
    .label = Security
librewolf-ocsp-checkbox =
    .label = Enforce OCSP hard-fail
librewolf-goog-safe-checkbox =
    .label = Enable Google Safe Browsing
librewolf-goog-safe-download-checkbox =
    .label = Scan downloads
# In-depth descriptions
librewolf-ocsp-description = Prevent connecting to a website if the OCSP check cannot be performed.
librewolf-ocsp-warning1 = This increases security, but it will cause breakage when an OCSP server is down.
librewolf-goog-safe-description = If you are worried about malware and phishing, consider enabling it.
librewolf-goog-safe-warning1 = Disabled over censorship concerns but recommended for less advanced users. All the checks happen locally.
librewolf-goog-safe-download-description = Allow Safe Browsing to scan your downloads to identify suspicious files.
librewolf-goog-safe-download-warning1 = All the checks happen locally.
# Footer
librewolf-footer = Useful links
librewolf-config-link = All advanced settings (about:config)
librewolf-open-profile = Open user profile directory

## Privacy & Security preferences

content-blocking-section-top-level-description = LibreWolf supports - and it enables by default - Enhanced Tracking Protection in Strict mode. This is one of the most important settings in the browser, as it provides state partitioning, s>

## Permissions

permissions-webgl2 =
    .label = WebGL