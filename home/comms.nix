{ pkgs, ... }:

{
  home.packages = with pkgs; [
    discord
    discordo
    telegram-desktop
    nchat
    ferdium
    calcure # TUI calendar
  ];
}
