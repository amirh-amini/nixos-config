{ pkgs, ... }:

{
  imports = [ ./yazi.nix ];

  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.qtsvg
    nautilus
  ];
}
