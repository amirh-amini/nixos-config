{
  # TODO: Remove this module if OBS virtual-camera support is not used.
  # The loaded v4l2loopback module currently has no consumers.
  # OBS itself is installed by Home Manager. This module only provides the
  # privileged v4l2loopback support required by its virtual camera.
  programs.obs-studio = {
    enable = true;
    package = null;
    enableVirtualCamera = true;
  };
}
