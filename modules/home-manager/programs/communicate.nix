{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # TODO removing these extra things for now
    discord
    discordo
    telegram-desktop
    nchat
    ferdium
  ];
}

