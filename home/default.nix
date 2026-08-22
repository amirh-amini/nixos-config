{ config, pkgs, ... }:

{
  imports = [
    # desk — the Sway session stack
    ./desk/sway.nix
    ./desk/fuzzel.nix
    ./desk/waybar.nix
    ./desk/screenshot.nix
    ./desk/session.nix
    ./desk/pointer.nix
    ./desk/lock.nix

    # code — development environment
    ./code/zsh.nix
    ./code/git.nix
    ./code/kitty.nix
    ./code/ghostty.nix
    ./code/zed.nix
    ./code/direnv.nix
    ./code/python-tools.nix
    ./code/packages.nix
    ./code/neovim.nix
    ./code/vscode.nix

    # agents — AI coding tools (future fast lane)
    ./agents/ai-tools.nix

    # singletons
    ./comms.nix
    ./secrets.nix

    # browse — on trial: zen + helium vs the parked chrome/firefox
    ./browse/zen.nix
    ./browse/helium.nix
    ./browse/qutebrowser.nix

    # media
    ./media/sioyek.nix
    ./media/video.nix
    ./media/vimiv.nix
    ./media/packages.nix

    # files
    ./files/yazi.nix
    ./files/dolphin.nix
    ./files/packages.nix
  ];

  home.username = "amirh";
  home.homeDirectory = "/home/amirh";

  # XDG user directories (~/.config/user-dirs.dirs). Without this, GLib's
  # get_user_special_dir(DOWNLOAD) returns null and GTK apps that ask for the
  # Downloads folder (e.g. Varia) crash. Also creates the folders on switch.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  services.wpaperd = {
    enable = true;
    settings = {
      any = {
        path = "/home/amirh/wallpaper";
      };
    };
  };

  # Browsers — parked until the zen/helium decision (see BACKLOG.md).
  home.packages = with pkgs; [
    firefox
    google-chrome
  ];

  # Neovim is configured in ./code/neovim.nix (real Lua config + Nix provisioning).

  # Gnome Settings (dconf)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "blue";
    };
  };

  home.stateVersion = "25.11";
}
