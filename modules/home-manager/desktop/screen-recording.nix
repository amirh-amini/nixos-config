{ pkgs, ... }:

# Screen recording (companions to the screenshot stack):
#   wl-screenrec — CLI Wayland screen recorder, VA-API hardware encoding
#                  (uses the Intel GPU on this hybrid setup).
#   obs-studio   — full recording/streaming suite. Wayland screen capture
#                  works via the PipeWire screencast portal already provided
#                  by xdg-desktop-portal-wlr (see sway.nix); pick
#                  "Screen Capture (PipeWire)" as the source.
{
  home.packages = with pkgs; [
    wl-screenrec
    obs-studio
  ];
}
