{ pkgs, ... }:

{
  home.packages = [ pkgs.gedit ];

  # Zed editor — minimal start; settings grow only with real use.
  programs.zed-editor = {
    enable = true;
  };
}
