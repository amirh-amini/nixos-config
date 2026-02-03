{ pkgs, config, ... }:

{
  programs.qutebrowser = {
    enable = true;

    # Install python packages for specific functionality
    package = pkgs.qutebrowser.override {
      enableWideVine = true; # DRM support for Netflix/Spotify
    };

    # https://www.qutebrowser.org/doc/help/settings.html
    settings = {

      # =====================================================================
      # ALIASES & BINDINGS (Skipped as per request for no aliases/bindings)
      # =====================================================================
      # aliases = { ... };
      # bindings.commands = { ... };
      # bindings.default = { ... };
      # bindings.key_mappings = { ... };

      # =====================================================================
      # GENERAL / SESSION
      # =====================================================================
      
      # Time interval (in milliseconds) between auto4-saves of config/cookies/etc.
      # Default: 15000
      "auto_save.interval" = 15000;

      # Always restore open sites when qutebrowser is reopened.
      "auto_save.session" = true;

      # Backend to use to display websites. (webengine is Chromium based)
      # Valid values: webengine, webkit
      # Default: webengine
      "backend" = "webengine";

      # When to show a changelog after qutebrowser was upgraded.
      # Valid values: major, minor, patch, never
      # Default: minor
      "changelog_after_upgrade" = "patch";

      # Require a confirmation before quitting the application.
      # Valid values: always, multiple-tabs, downloads, never
      # Default: never
      "confirm_quit" = "downloads";

      # Name of the session to save by default.
      # Default: empty
      # "session.default_name" = "";

      # Load a restored tab as soon as it takes focus.
      # Default: false
      "session.lazy_restore" = true; # save resources

      # Automatically start playing <video> elements.
      # Default: true
      "content.autoplay" = false;

      # Enable the ad/host blocker
      # Default: true
      "content.blocking.enabled" = true;

      # Block subdomains of blocked hosts.
      # Default: true
      "content.blocking.hosts.block_subdomains" = true;

      # Which method of blocking ads should be used.
      # Valid values: auto, adblock, hosts, both
      # Default: auto
      "content.blocking.method" = "auto";

      # Enable support for the HTML 5 web application cache feature.
      # Default: true
      "content.cache.appcache" = true;

      # Maximum number of pages to hold in the global memory page cache. (QtWebKit only)
      # "content.cache.maximum_pages" = 0;

      # Size (in bytes) of the HTTP network cache. Null to use the default value.
      # "content.cache.size" = null;

      # Allow websites to read canvas elements. (Fingerprinting risk)
      # Default: true
      "content.canvas_reading" = false; 

      # Which cookies to accept.
      # Valid values: all, no-3rdparty, no-unknown-3rdparty, never
      # Default: all
      "content.cookies.accept" = "no-unknown-3rdparty";

      # Store cookies.
      # Default: true
      "content.cookies.store" = true;

      # Default encoding to use for websites.
      # Default: iso-8859-1
      "content.default_encoding" = "utf-8";

      # Allow websites to share screen content.
      # Valid values: true, false, ask
      # Default: ask
      "content.desktop_capture" = "ask";

      # Try to pre-fetch DNS entries to speed up browsing.
      # Default: true
      "content.dns_prefetch" = true;

      # Limit fullscreen to the browser window (does not expand to fill the screen).
      # Default: false
      "content.fullscreen.window" = true;

      # Allow websites to request geolocations.
      # Valid values: true, false, ask
      # Default: ask
      "content.geolocation" = "ask";

      # Value to send in the DNT header.
      # Default: true
      "content.headers.do_not_track" = true;

      # When to send the Referer header.
      # Valid values: always, never, same-domain
      # Default: same-domain
      "content.headers.referer" = "same-domain";

      # User agent to send.
      # Default: <dynamic>
      # "content.headers.user_agent" = ""; # Leave default to avoid breakage

      # Enable hyperlink auditing (<a ping>).
      # Default: false
      "content.hyperlink_auditing" = false;

      # Load images automatically in web pages.
      # Default: true
      "content.images" = true;

      # Show javascript alerts.
      # Default: true
      "content.javascript.alert" = true;

      # Allow JavaScript to close tabs.
      # Default: false
      "content.javascript.can_close_tabs" = false;

      # Allow JavaScript to open new tabs without user interaction.
      # Default: false
      "content.javascript.can_open_tabs_automatically" = false;

      # Allow JavaScript to read from or write to the clipboard.
      # Valid values: none, access, access-paste, ask
      # Default: ask
      "content.javascript.clipboard" = "access-paste";

      # Enable JavaScript.
      # Default: true
      "content.javascript.enabled" = true;

      # Use the standard JavaScript modal dialog for alert() and confirm().
      # Default: false
      "content.javascript.modal_dialog" = false;

      # Show javascript prompts.
      # Default: true
      "content.javascript.prompt" = true;

      # Enable support for HTML 5 local storage and Web SQL.
      # Default: true
      "content.local_storage" = true;

      # Allow websites to record audio/video.
      "content.media.audio_capture" = "ask";
      "content.media.video_capture" = "ask";
      "content.media.audio_video_capture" = "ask";

      # Allow websites to lock your mouse pointer.
      # Default: ask
      "content.mouse_lock" = "ask";

      # Automatically mute tabs.
      # Default: false
      "content.mute" = false;

      # Allow websites to show notifications.
      # Valid values: true, false, ask
      # Default: ask
      "content.notifications.enabled" = false;

      # Display PDF files via PDF.js in the browser without showing a download prompt.
      # Default: false
      "content.pdfjs" = true;

      # Allow websites to request persistent storage quota.
      # Default: ask
      "content.persistent_storage" = "ask";

      # Enable plugins in Web pages.
      # Default: false
      "content.plugins" = true;

      # Request websites to minimize non-essentials animations and motion.
      # Default: false
      "content.prefers_reduced_motion" = true;

      # Open new windows in private browsing mode.
      # Default: false
      "content.private_browsing" = false;

      # Proxy to use. System, none, or url.
      # Default: system
      "content.proxy" = "system";

      # Allow websites to register protocol handlers.
      # Default: ask
      "content.register_protocol_handler" = "ask";

      # How to proceed on TLS certificate errors.
      # Valid values: ask, ask-block-thirdparty, block, load-insecurely
      # Default: ask
      "content.tls.certificate_errors" = "ask";

      # Enable WebGL.
      # Default: true
      "content.webgl" = true;

      # Monitor load requests for cross-site scripting attempts.
      # Default: false
      "content.xss_auditing" = true;

      # =====================================================================
      # DOWNLOADS
      # =====================================================================
      
      # Directory to save downloads to.
      "downloads.location.directory" = "~/Downloads";

      # Prompt the user for the download location.
      # Default: true
      "downloads.location.prompt" = false;

      # Remember the last used download directory.
      # Default: true
      "downloads.location.remember" = true;

      # What to display in the download filename input.
      # Valid values: path, filename, both
      # Default: path
      "downloads.location.suggestion" = "both";

      # Default program used to open downloads.
      # "downloads.open_dispatcher" = "";

      # Where to show the downloaded files.
      # Valid values: top, bottom
      # Default: top
      "downloads.position" = "bottom";

      # Automatically abort insecure (HTTP) downloads originating from secure (HTTPS) pages.
      # Default: true
      "downloads.prevent_mixed_content" = true;

      # Duration (in milliseconds) to wait before removing finished downloads.
      # -1 = never remove
      # Default: -1
      "downloads.remove_finished" = -1;

      # Editor (and arguments) to use for the edit-* commands.
      # Default: gvim -f {file} -c normal {line}G{column0}l
      "editor.command" = [ "kitty" "-e" "nvim" "{file}" "-c" "normal {line}G{column0}l" ];

      # Encoding to use for the editor.
      # Default: utf-8
      "editor.encoding" = "utf-8";

      # Delete the temporary file upon closing the editor.
      # Default: true
      "editor.remove_file" = true;

      # Handler for selecting file(s) in forms.
      # Valid values: default, external
      # Default: default
      "fileselect.handler" = "external";
      "fileselect.single_file.command" = [ "kitty" "-e" "ranger" "--choosefile={}" ];
      "fileselect.multiple_files.command" = [ "kitty" "-e" "ranger" "--choosefiles={}" ];
      "fileselect.folder.command" = [ "kitty" "-e" "ranger" "--choosedir={}" ];

      # =====================================================================
      # HINTS (POWER USER KEYBOARD NAV)
      # =====================================================================
      
      # When a hint can be automatically followed without pressing Enter.
      # Valid values: always, unique-match, full-match, never
      # Default: unique-match
      "hints.auto_follow" = "unique-match";

      # Duration (in milliseconds) to ignore normal-mode key bindings after a successful auto-follow.
      # Default: 0
      "hints.auto_follow_timeout" = 0;

      # CSS border value for hints.
      # Default: 1px solid #E3BE23
      # "hints.border" = "1px solid #E3BE23";

      # Characters used for hint strings.
      # Default: asdfghjkl
      "hints.chars" = "asdfghjkl;gh"; # Home row optimized

      # Dictionary file to be used by the word hints.
      # "hints.dictionary" = "/usr/share/dict/words";

      # Hide unmatched hints in rapid mode.
      # Default: true
      "hints.hide_unmatched_rapid_hints" = true;

      # Leave hint mode when starting a new page load.
      # Default: false
      "hints.leave_on_load" = true;

      # Minimum number of characters used for hint strings.
      # Default: 1
      "hints.min_chars" = 1;

      # Mode to use for hints.
      # Valid values: number, letter, word
      # Default: letter
      "hints.mode" = "letter";

      # Scatter hint key chains (like Vimium) or not (like dwb).
      # Default: true
      "hints.scatter" = true;

      # Make characters in hint strings uppercase.
      # Default: false
      "hints.uppercase" = true; # Easier to read/type quickly

      # =====================================================================
      # INPUT
      # =====================================================================

      # Allow Escape to quit the crash reporter.
      "input.escape_quits_reporter" = true;

      # Enter insert mode if an editable element is clicked.
      # Default: true
      "input.insert_mode.auto_enter" = true;

      # Leave insert mode if a non-editable element is clicked.
      # Default: true
      "input.insert_mode.auto_leave" = true;

      # Automatically enter insert mode if an editable element is focused after loading the page.
      # Default: false
      "input.insert_mode.auto_load" = true; # Speed up form entry

      # Leave insert mode when starting a new page load.
      # Default: true
      "input.insert_mode.leave_on_load" = true;

      # Switch to insert mode when clicking flash and other plugins.
      # Default: false
      "input.insert_mode.plugins" = false;

      # Include hyperlinks in the keyboard focus chain when tabbing.
      # Default: true
      "input.links_included_in_focus_chain" = false; # Rely on hints instead of Tab

      # Interpret number prefixes as counts for bindings.
      # Default: true
      "input.match_counts" = true;

      # Whether the underlying Chromium should handle media keys.
      # Default: true
      "input.media_keys" = true;

      # Enable back and forward buttons on the mouse.
      # Default: true
      "input.mouse.back_forward_buttons" = true;

      # Enable Opera-like mouse rocker gestures.
      # Default: false
      "input.mouse.rocker_gestures" = false;

      # Enable spatial navigation (arrow keys).
      # Default: false
      "input.spatial_navigation" = false;

      # =====================================================================
      # LOGGING & MESSAGES
      # =====================================================================
      
      # Level for console (stdout/stderr) logs.
      "logging.level.console" = "error";

      # Level for in-memory logs.
      "logging.level.ram" = "debug";

      # Duration (in milliseconds) to show messages in the statusbar for.
      # Default: 3000
      "messages.timeout" = 3000;

      # =====================================================================
      # OPEN TARGETS
      # =====================================================================

      # How to open links in an existing instance if a new one is launched.
      # Valid values: tab, tab-bg, tab-silent, tab-bg-silent, window, private-window
      # Default: tab
      "new_instance_open_target" = "tab-bg";

      # Which window to choose when opening links as new tabs.
      # Valid values: first-opened, last-opened, last-focused, last-visible
      # Default: last-focused
      "new_instance_open_target_window" = "last-focused";

      # =====================================================================
      # PROMPTS & FILEBROWSER
      # =====================================================================

      # Show a filebrowser in download prompts.
      # Default: true
      "prompt.filebrowser" = true;

      # Rounding radius (in pixels) for the edges of prompts.
      "prompt.radius" = 8;

      # =====================================================================
      # QT / PERFORMANCE / WORKAROUNDS
      # =====================================================================

      # Additional arguments to pass to Qt.
      # "qt.args" = [];

      # Enables Web Platform features that are in development.
      # Valid values: always, auto, never
      # Default: auto
      "qt.chromium.experimental_web_platform_features" = "auto";

      # When to use Chromium's low-end device mode.
      # Valid values: always, auto, never
      # Default: auto
      "qt.chromium.low_end_device_mode" = "never"; # Assume powerful laptop

      # Which Chromium process model to use.
      # Default: process-per-site-instance
      "qt.chromium.process_model" = "process-per-site-instance";

      # What sandboxing mechanisms in Chromium to use.
      # Default: enable-all
      "qt.chromium.sandboxing" = "enable-all";

      # Turn on Qt HighDPI scaling.
      # Default: false
      "qt.highdpi" = true;

      # Force software rendering for QtWebEngine.
      # Default: none
      "qt.force_software_rendering" = "none";

      # =====================================================================
      # SCROLLING
      # =====================================================================

      # When/how to show the scrollbar.
      # Valid values: always, never, when-searching, overlay
      # Default: overlay
      "scrolling.bar" = "when-searching"; # Minimalist

      # Enable smooth scrolling for web pages.
      # Default: false
      "scrolling.smooth" = true; # Better UX

      # =====================================================================
      # SEARCH
      # =====================================================================

      # When to find text on a page case-insensitively.
      # Valid values: always, never, smart
      # Default: smart
      "search.ignore_case" = "smart";

      # Find text on a page incrementally.
      # Default: true
      "search.incremental" = true;

      # Wrap around at the top and bottom of the page when advancing through text matches.
      # Default: true
      "search.wrap" = true;

      # =====================================================================
      # STATUSBAR
      # =====================================================================

      # Padding (in pixels) for the statusbar.
      # "statusbar.padding" = { bottom = 1; left = 0; right = 0; top = 1; };

      # Position of the status bar.
      # Valid values: top, bottom
      # Default: bottom
      "statusbar.position" = "bottom";

      # When to show the statusbar.
      # Valid values: always, never, in-mode
      # Default: always
      "statusbar.show" = "in-mode"; # Minimalist: Only show when typing command

      # List of widgets displayed in the statusbar.
      # Default: keypress, search_match, url, scroll, history, tabs, progress
      "statusbar.widgets" = [ "keypress" "search_match" "url" "scroll" "history" "tabs" "progress" ];

      # =====================================================================
      # TABS
      # =====================================================================

      # Open new tabs (middleclick/ctrl+click) in the background.
      # Default: true
      "tabs.background" = true;

      # Mouse button with which to close tabs.
      # Default: middle
      "tabs.close_mouse_button" = "middle";

      # Scaling factor for favicons in the tab bar.
      # Default: 1.0
      "tabs.favicons.scale" = 1.0;

      # When to show favicons in the tab bar.
      # Valid values: always, never, pinned
      # Default: always
      "tabs.favicons.show" = "always";

      # Maximum stack size to remember for tab switches (-1 for no maximum).
      # Default: 10
      "tabs.focus_stack_size" = 100;

      # Width (in pixels) of the progress indicator (0 to disable).
      # Default: 3
      "tabs.indicator.width" = 3;

      # How to behave when the last tab is closed.
      # Valid values: ignore, blank, startpage, default-page, close
      # Default: ignore
      "tabs.last_close" = "close";

      # Maximum width (in pixels) of tabs (-1 for no maximum).
      "tabs.max_width" = -1;

      # Minimum width (in pixels) of tabs (-1 for the default minimum size behavior).
      "tabs.min_width" = -1;

      # When switching tabs, what input mode is applied.
      # Valid values: persist, restore, normal
      # Default: normal
      "tabs.mode_on_change" = "normal";

      # Switch between tabs using the mouse wheel.
      # Default: true
      "tabs.mousewheel_switching" = false; # Prevent accidental switches

      # Position of new tabs opened from another tab.
      # Valid values: prev, next, first, last
      # Default: next
      "tabs.new_position.related" = "next";

      # Stack related tabs on top of each other when opened consecutively.
      # Default: true
      "tabs.new_position.stacking" = true;

      # Position of new tabs which are not opened from another tab.
      # Valid values: prev, next, first, last
      # Default: last
      "tabs.new_position.unrelated" = "last";

      # Force pinned tabs to stay at fixed URL.
      # Default: true
      "tabs.pinned.frozen" = true;

      # Shrink pinned tabs down to their contents.
      # Default: true
      "tabs.pinned.shrink" = true;

      # Position of the tab bar.
      # Valid values: top, bottom, left, right
      # Default: top
      "tabs.position" = "top";

      # Which tab to select when the focused tab is removed.
      # Valid values: prev, next, last-used
      # Default: next
      "tabs.select_on_remove" = "last-used"; # Better flow for power users

      # When to show the tab bar.
      # Valid values: always, never, multiple, switching
      # Default: always
      "tabs.show" = "multiple"; # Hide if only one tab

      # Duration (in milliseconds) to show the tab bar before hiding it when tabs.show is set to switching.
      # Default: 800
      "tabs.show_switching_delay" = 800;

      # Open a new window for every tab.
      # Default: false
      "tabs.tabs_are_windows" = false;

      # Alignment of the text inside of tabs.
      # Valid values: left, right, center
      # Default: left
      "tabs.title.alignment" = "left";

      # Format to use for the tab title.
      # Default: {audio}{index}: {current_title}
      "tabs.title.format" = "{audio}{index}: {current_title}";

      # Show tooltips on tabs.
      # Default: true
      "tabs.tooltips" = true;

      # Width (in pixels or as percentage of the window) of the tab bar if it's vertical.
      # Default: 15%
      "tabs.width" = "15%";

      # Wrap when changing tabs.
      # Default: true
      "tabs.wrap" = true;

      # =====================================================================
      # URL & NAVIGATION
      # =====================================================================

      # What search to start when something else than a URL is entered.
      # Valid values: naive, dns, never, schemeless
      # Default: naive
      "url.auto_search" = "naive";

      # Page to open if :open -t/-b/-w is used without URL.
      # Default: https://start.duckduckgo.com/
      "url.default_page" = "about:blank";

      # URL segments where :navigate increment/decrement will search for a number.
      # Default: path, query
      "url.incdec_segments" = [ "path" "query" ];

      # Open base URL of the searchengine if a searchengine shortcut is invoked without parameters.
      # Default: false
      "url.open_base_url" = true;

      # Search engines which can be used via the address bar.
      # Default: {'DEFAULT': 'https://duckduckgo.com/?q={}'}
      "url.searchengines" = {
        "DEFAULT" = "https://duckduckgo.com/?q={}";
        "g" = "https://google.com/search?q={}";
        "np" = "https://search.nixos.org/packages?channel=unstable&query={}";
        "no" = "https://search.nixos.org/options?channel=unstable&query={}";
        "yt" = "https://www.youtube.com/results?search_query={}";
      };

      # Page(s) to open at the start.
      # Default: https://start.duckduckgo.com
      "url.start_pages" = [ "about:blank" ];

      # URL parameters to strip when yanking a URL.
      # Default: ref, utm_source, utm_medium, utm_campaign, utm_term, utm_content, utm_name
      "url.yank_ignored_parameters" = [ "ref" "utm_source" "utm_medium" "utm_campaign" "utm_term" "utm_content" "utm_name" "fbclid" "mc_eid" ];

      # =====================================================================
      # WINDOW & ZOOM
      # =====================================================================

      # Hide the window decoration.
      # Default: false
      "window.hide_decoration" = false;

      # Format to use for the window title.
      # Default: {perc}{current_title}{title_sep}qutebrowser
      "window.title_format" = "{perc}{current_title}{title_sep}qutebrowser";

      # Set the main window background to transparent.
      # Default: false
      "window.transparent" = false;

      # Default zoom level.
      # Default: 100%
      "zoom.default" = "100%";

      # Number of zoom increments to divide the mouse wheel movements to.
      # Default: 512
      "zoom.mouse_divider" = 512;

      # =====================================================================
      # COLORS & FONTS (MINIMAL THEMING - MOSTLY DEFAULTS)
      # =====================================================================
      
      # Render all web contents using a dark theme.
      # Default: false
      "colors.webpage.darkmode.enabled" = true; # Set to false if you prefer original colors
      "colors.webpage.darkmode.algorithm" = "lightness-cielab";
      "colors.webpage.darkmode.policy.images" = "smart";
      "colors.webpage.preferred_color_scheme" = "auto";

      # Background color for webpages if unset.
      # "colors.webpage.bg" = "white";

      # --- Statusbar Colors (Left default for minimal rice) ---
      # "colors.statusbar.normal.bg" = "black";
      # "colors.statusbar.normal.fg" = "white";
      # "colors.statusbar.insert.bg" = "darkgreen";
      # "colors.statusbar.passthrough.bg" = "darkblue";
      # "colors.statusbar.command.bg" = "black";

      # --- Tab Colors ---
      # "colors.tabs.bar.bg" = "#555555";
      # "colors.tabs.selected.even.bg" = "black";
      # "colors.tabs.selected.odd.bg" = "black";
      
      # --- Fonts ---
      # "fonts.default_family" = "Monospace";
      # "fonts.default_size" = "10pt";
    };
  };
}
