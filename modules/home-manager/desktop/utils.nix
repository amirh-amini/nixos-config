{ pkgs, ... }:

{
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    backgroundColor = "#24283b";
    borderColor = "#7aa2f7";
    textColor = "#c0caf5";
    borderRadius = 5;
    borderSize = 2;
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  services.swayosd.enable = true;

  home.packages = with pkgs; [
    wl-clipboard    
    cliphist        
    
    nwg-displays    
    
    pulsemixer      # Audio mixer (TUI)
    pamixer         # Audio control (CLI for keys)
    pwvucontrol     # Audio control (GUI - backup)
    
    bluetui         # Bluetooth (TUI)
    blueman         # Bluetooth (GUI - backup)
  ];
}

