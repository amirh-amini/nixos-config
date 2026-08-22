{
  pkgs,
  ...
}:

{
  # Media apps without their own module — config-less.
  home.packages = with pkgs; [
    spotify
    vlc
    pdftk # PDF page surgery (kept from former 4now.nix)
  ];
}
