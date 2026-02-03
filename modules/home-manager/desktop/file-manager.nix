{ pkgs, ... }:

{
  environment.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.qtsvg
  ];
}

