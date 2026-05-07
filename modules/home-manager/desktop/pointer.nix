{ pkgs, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;  # Docker/XWayland support
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 16;
  };
}

# TODO did we really needed to have a file for this one? put it in `sway.nix` 
