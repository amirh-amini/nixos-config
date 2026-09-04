{
  pkgs,
  ...
}:

{
  imports = [
    ./mpv.nix
    ./obs.nix
  ];

  # Media apps without their own module — config-less.
  home.packages = with pkgs; [
    spotify
    vlc
    vimiv-qt
  ];
}
