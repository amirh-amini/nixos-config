{
  services.libinput.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # Swap Left Alt and Left Super.
            leftalt = "leftmeta";
            leftmeta = "leftalt";

            # Caps Lock: tap for Escape, hold for Control.
            capslock = "overload(control, esc)";
          };
        };
      };
    };
  };
}
