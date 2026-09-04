{ inputs, ... }:

{
  imports = [
    # Desktop
    ./sway.nix
    ./fuzzel.nix
    ./waybar.nix
    ./session.nix
    ./lock.nix
    ./screenshot.nix
    ./voxtype.nix

    # Programs and tools
    ./browsers.nix
    ./qutebrowser.nix
    ./terminals.nix
    ./editors.nix
    ./file-managers.nix
    ./yazi.nix
    ./notes.nix
    ./media.nix
    ./video.nix
    ./sioyek.nix
    ./comms.nix

    # Development and agents
    ./zsh.nix
    ./git.nix
    ./direnv.nix
    ./python.nix
    ./cli-tools.nix
    ./neovim.nix
    ./vscode.nix
    inputs.codex-desktop-linux.homeManagerModules.default
    ./codex-desktop.nix
    ./ai-tools.nix
    ./secrets.nix
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
