{
  pkgs,
  ...
}:

{
  # Media apps without their own module — config-less.
  home.packages = with pkgs; [
    spotify
    vlc
    pdftk
    vimiv-qt
  ];
}
