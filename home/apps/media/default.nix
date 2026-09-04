{
  pkgs,
  ...
}:

{
  imports = [
    ./mpv.nix
    ./obs.nix
  ];

  home.packages = with pkgs; [
    spotify
    vlc
    vimiv-qt
  ];
}
