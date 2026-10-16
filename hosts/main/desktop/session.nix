{
  # TODO: Decide whether X11 login sessions are needed. If not, disable the X
  # server and set services.displayManager.ly.x11Support to false.
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  programs.sway.enable = true;

  # TODO: Verify that the Qt and WebKit overrides still solve current problems;
  # remove global compatibility variables that are no longer necessary.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    WEBKIT_DISABLE_DMABUF_RENDERER = "1";
  };
}
