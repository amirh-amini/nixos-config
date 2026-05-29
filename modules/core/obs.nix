{ ... }:

# OBS Studio, system-level — needed specifically for the virtual camera.
# `enableVirtualCamera` loads the v4l2loopback kernel module and writes the
# modprobe options (devices=1, video_nr=1, card_label="OBS Cam",
# exclusive_caps=1) plus polkit access so OBS can start the virtual webcam
# that browsers/Zoom/etc. consume. Normal screen recording stays on
# wl-screenrec (modules/home-manager/desktop/screen-recording.nix).
{
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };
}
