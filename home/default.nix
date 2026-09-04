{
  imports = [
    ./desktop
    ./apps
    ./shell
    ./development
    ./security.nix
  ];

  home.username = "amirh";
  home.homeDirectory = "/home/amirh";

  # XDG user directories (~/.config/user-dirs.dirs). Without this, GLib's
  # get_user_special_dir(DOWNLOAD) returns null and GTK apps that ask for the
  # Downloads folder (e.g. Varia) crash. Also creates the folders on switch.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
  };

  services.wpaperd = {
    enable = true;
    settings = {
      any = {
        path = "/home/amirh/wallpaper";
      };
    };
  };

  # Gnome Settings (dconf)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "blue";
    };
  };

  home.stateVersion = "25.11";
}
