{ pkgs, ... }:

{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # 1. Swap Left Alt and Left Super
            leftalt = "leftmeta";
            leftmeta = "leftalt";

            # 2. Caps Lock behavior
            # capslock = "overload(control, esc)";
          };
        };
      };
    };
  };
}

