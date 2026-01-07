{ config, pkgs, ... }:

{
  home-manager.users.amirh = {
    
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
      zsh
      
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

    # Program Configurations
    programs.git = {
      enable = true;
      userName = "amirh-amini";
      userEmail = "169299589+amirh-amini@users.noreply.github.com";
      extraConfig = {
      	init.defaultBranch = "main";
      };
    };

    programs.emacs.enable = true;

    # Shell Config
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw";
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
  };
}
