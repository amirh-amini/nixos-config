{
  pkgs,
  ...
}:

{
  programs = {
    bat.enable = true;
    btop.enable = true;
    htop.enable = true;
    tmux.enable = true;
    zellij.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # Utilities without useful Home Manager modules.
  home.packages = with pkgs; [
    ripgrep
    fd
    jq

    nvtopPackages.full
    dust
    btdu
    fastfetch

    tree
    zip
    unzip
  ];
}
