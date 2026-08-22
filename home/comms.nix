{ pkgs, ... }:

{
  home.packages = with pkgs; [
    discord
    discordo
    telegram-desktop
    nchat
    ferdium
    calcure # TUI calendar (was in the old home.packages grab-bag)
  ];
}
