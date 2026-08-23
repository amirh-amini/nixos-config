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
    # alacritty retired — ghostty (home/code/ghostty.nix) is the second terminal
    lazygit
    lazydocker
    # GitButler GUI — via llm-agents: newer release (0.22 vs nixpkgs 0.19)
    # and prebuilt on cache.numtide.com; the nixpkgs build compiles its
    # Rust backend locally.
    pkgs.llm-agents.gitbutler
  ];
}
