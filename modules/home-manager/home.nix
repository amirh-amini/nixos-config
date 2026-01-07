{ config, pkgs, ... }:

{
  imports = [
    ./dev/zsh.nix
    ./dev/git.nix
  ];

  home.username = "amirh";
  home.homeDirectory = "/home/amirh";

  # User Packages
  home.packages = with pkgs; [
    # Productivity
    obsidian
    firefox
    google-chrome
    spotify
    vlc
    gedit

    # Terminals & Shells
    alacritty
    kitty
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

  programs.emacs.enable = true;

  # Gnome Settings (dconf)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "blue";
    };
  };

  home.stateVersion = "25.11";
}

