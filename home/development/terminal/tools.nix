{
  pkgs,
  ...
}:

{
  # General-purpose terminal tools; coding-specific tools live one level up.
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    fzf
    jq
    htop
    btop
    nvtopPackages.full
    dust
    btdu
    fastfetch
    tree
    zip
    unzip
    tmux
    zellij
  ];
}
