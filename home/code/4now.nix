{ pkgs, ... }:

{
  home.packages = [
    pkgs.antigravity-fhs
    pkgs.code-cursor-fhs
    pkgs.lmstudio
    pkgs.pdftk
  ];
}

# TODO clean this.
