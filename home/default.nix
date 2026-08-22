{ config, pkgs, ... }:

{
  imports = [
    # desk — the Sway session stack
    ./desk/sway.nix
    ./desk/fuzzel.nix
    ./desk/waybar.nix
    ./desk/screenshot.nix
    ./desk/utils.nix
    ./desk/pointer.nix
    ./desk/lock.nix

    # code — development environment
    ./code/zsh.nix
    ./code/git.nix
    ./code/kitty.nix
    ./code/direnv.nix
    ./code/python-tools.nix
    ./code/neovim.nix
    ./code/vscode.nix
    ./code/4now.nix

    # agents — AI coding tools (future fast lane)
    ./agents/ai-tools.nix

    # singletons
    ./comms.nix
    ./qutebrowser.nix
    ./secrets.nix

    # media
    ./media/sioyek.nix
    ./media/video.nix
    ./media/vimiv.nix

    # files
    ./files/yazi.nix
    ./files/dolphin.nix
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

  # TODO I don't like how some programs are here and some are not. They should all be moved to different dir and noting should be here.

  # User Packages
  home.packages = with pkgs; [
    # Productivity
    obsidian
    firefox
    google-chrome
    spotify
    vlc
    gedit
    calcure
    nautilus # TEMP (B7): GNOME session gone; re-homes to files/ in C5

    # Terminals & Shells
    alacritty
    zellij
    tmux

    # Dev Tools
    # vscode — now managed declaratively in ./dev/vscode.nix (programs.vscode)
    ripgrep
    fd
    bat
    fzf
    htop
    btop
    fastfetch
    tree

    # Archives
    zip
    unzip
  ];

  # Neovim is configured in ./dev/neovim.nix (real Lua config + Nix provisioning).

  # Gnome Settings (dconf)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "blue";
    };
  };

  home.stateVersion = "25.11";
}
