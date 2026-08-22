{ pkgs, ... }:

# vimiv-qt — Qt image viewer with vim-like keybindings.
# No home-manager `programs.vimiv` module exists, so it ships as a package.
# Config (if desired) lives in ~/.config/vimiv/{vimiv.conf,keys.conf,styles/}.
{
  home.packages = [ pkgs.vimiv-qt ];
}
