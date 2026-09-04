{ pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "top";
        width = 50;
        font = "monospace:size=11";
        icon-theme = "hicolor";
        icons-enabled = "no";

        horizontal-pad = 10;
        vertical-pad = 8;
        inner-pad = 5;

        line-height = 20;
      };

      colors = {
        background = "2b2d3aff";
        text = "e2e2e3ff";
        match = "9cd1bbff";
        selection = "3d4455ff";
        selection-text = "e2e2e3ff";
        selection-match = "9cd1bbff";
        border = "3d4455ff";
      };

      border = {
        width = 2;
        radius = 0;
      };
    };
  };
}
