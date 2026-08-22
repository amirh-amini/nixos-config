{
  pkgs,
  ...
}:

{
  # CLI workbench: text tools, monitors, archives, multiplexers, terminals.
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    fzf
    jq
    gh
    htop
    btop
    fastfetch
    tree
    zip
    unzip
    tmux
    zellij
    alacritty # second terminal (kitty is primary)
    lazygit
    lazydocker
    gitbutler # Git client (GUI)
  ];
}
