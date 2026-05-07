{ config, pkgs, ... }:

{
  imports = [
    ./dev/zsh.nix
    ./dev/git.nix
    ./dev/kitty.nix
    ./desktop/sway.nix
    ./desktop/fuzzel.nix
    ./desktop/waybar.nix
    ./desktop/utils.nix
    ./desktop/pointer.nix
    ./desktop/lock.nix
    ./desktop/file-manager.nix
    ./programs/consume/sioyek.nix
    ./programs/communicate.nix
    ./programs/consume/video.nix
    ./programs/qutebrowser.nix
    ./programs/emacs
    ./dev/4now.nix
  ];

  home.username = "amirh";
  home.homeDirectory = "/home/amirh";
  
  services.wpaperd = {
    enable = true;
    settings = {
      any = { path = "/home/amirh/wallpaper"; };
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

    # Terminals & Shells
    alacritty
    zellij
    tmux

    # Dev Tools
    vscode
    ripgrep
    fd
    bat
    fzf
    htop
    btop
    neofetch
    gnome-tweaks
    tree

    # Archives
    zip
    unzip
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  # programs.emacs.enable = true;

  # Gnome Settings (dconf)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "blue";
    };
  };

  home.stateVersion = "25.11";
}

