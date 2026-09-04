{
  # OBS itself is installed by Home Manager. This module only provides the
  # privileged v4l2loopback support required by its virtual camera.
  programs.obs-studio = {
    enable = true;
    package = null;
    enableVirtualCamera = true;
  };
}
