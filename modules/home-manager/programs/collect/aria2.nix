{ config, pkgs, ... }:

# aria2 — fast multi-protocol, multi-source download utility (HTTP/FTP/BitTorrent).
# Docs: https://aria2.github.io/manual/en/html/aria2c.html
#
# The home-manager module just writes ~/.config/aria2/aria2.conf from `settings`
# and installs aria2c. Every `aria2c <url>` you run picks up the tuning below
# with no flags. Files land in ~/Downloads.
#
# Two ways to use it:
#   • CLI  — `aria2c "<url>"`           (uses the config below)
#   • GUI  — Varia (libadwaita app, also built on aria2) for point-and-click.

{
  programs.aria2 = {
    enable = true;

    # settings → aria2.conf (key=value). Sizes use aria2's K/M suffixes.
    settings = {
      dir = "${config.home.homeDirectory}/Downloads"; # where files land
      continue = true; # resume partial HTTP/FTP downloads
      max-concurrent-downloads = 5; # separate downloads at once

      # Speed: the four knobs that matter. Default is timid (1 conn/server);
      # this is the widely-used fast-but-polite sweet spot.
      max-connection-per-server = 16; # parallel connections to one host (cap 16)
      split = 16; # max segments per file
      min-split-size = "1M"; # let aria2 parallelise smaller files too

      # Don't clobber, do resume, keep the server's timestamp.
      always-resume = true;
      auto-file-renaming = true; # foo.zip → foo.1.zip instead of overwrite
      allow-overwrite = false;
      remote-time = true;

      file-allocation = "none"; # safe/lazy — friendly to btrfs CoW + snapper
      console-log-level = "warn"; # quieter terminal
    };
  };

  # Varia — simple GTK/libadwaita download manager on top of aria2.
  home.packages = [ pkgs.varia ];
}
