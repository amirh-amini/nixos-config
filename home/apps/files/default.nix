{ pkgs, ... }:

{
  imports = [ ./yazi.nix ];

  # TODO: Decide which stable Dolphin preferences are worth declaring. Home
  # Manager does not currently provide a dedicated Dolphin module.
  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.qtsvg
  ];
}
