{
  ...
}:

{
  # Graphical session stack: Ly greeter and Sway (Wayland).
  services.xserver.enable = true;
  services.displayManager.ly = {
    enable = true;
  };
  security.pam.services.ly = {
    text = ''
      auth      include login
      account   include login
      password  include login
      session   include login
    '';
  };

  programs.sway.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    WEBKIT_DISABLE_DMABUF_RENDERER = "1";
  };
}
