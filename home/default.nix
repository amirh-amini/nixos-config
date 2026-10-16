{
  imports = [
    ./desktop
    ./apps
    ./development
    ./security.nix
  ];

  home = {
    username = "amirh";
    homeDirectory = "/home/amirh";
    stateVersion = "25.11";
  };

  # XDG user directories (~/.config/user-dirs.dirs). Without this, GLib's
  # get_user_special_dir(DOWNLOAD) returns null and GTK apps that ask for the
  # Downloads folder (e.g. Varia) crash. Also creates the folders on switch.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
  };
}
