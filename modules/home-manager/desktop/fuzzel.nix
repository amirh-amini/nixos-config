{ pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        width = 40;
      };
      colors = {
        background = "24283bff";
        text = "c0caf5ff";
        match = "f7768eff";
        selection = "7aa2f7ff";
        selection-text = "24283bff";
        border = "7aa2f7ff";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}

