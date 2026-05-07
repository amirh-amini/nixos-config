{ pkgs, ... }:

{
  home.packages = [
    pkgs.antigravity-fhs
    pkgs.claude-code
    pkgs.code-cursor-fhs
    pkgs.lmstudio
    pkgs.pdftk
  ];
}

# TODO clean this.
