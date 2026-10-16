{ pkgs, ... }:

{
  home.packages = [
    pkgs.gh
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.nil
    pkgs.llm-agents.gitbutler
  ];
}
