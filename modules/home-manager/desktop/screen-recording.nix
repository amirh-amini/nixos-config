{ pkgs, ... }:

# Screen recording: wl-screenrec — CLI Wayland recorder with VA-API hardware
# encoding (uses the Intel GPU on this hybrid setup). This is the default for
# normal screen captures. OBS lives at the system level (modules/core/obs.nix)
# because it's enabled specifically for its virtual camera (v4l2loopback).
{
  home.packages = with pkgs; [
    wl-screenrec
  ];
}
