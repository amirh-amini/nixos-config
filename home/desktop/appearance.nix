{
  services.wpaperd = {
    enable = true;
    settings.any.path = "/home/amirh/wallpaper";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    accent-color = "blue";
  };
}
