{ pkgs, ... }:

{
  # 1. Notifications (Mako)
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    backgroundColor = "#24283b";
    borderColor = "#7aa2f7";
    textColor = "#c0caf5";
    borderRadius = 5;
    borderSize = 2;
  };

  # 2. Clipboard Manager (Cliphist)
  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  # 3. SwayOSD (Volume/Brightness UI)
  services.swayosd.enable = true;

  # 4. Packages requested
  home.packages = with pkgs; [
    wl-clipboard    # Clipboard cli
    cliphist        # Clipboard manager
    
    nwg-displays    # Monitor management (GUI)
    
    pulsemixer      # Audio mixer (TUI)
    pamixer         # Audio control (CLI for keys)
    pwvucontrol     # Audio control (GUI - backup)
    
    bluetui         # Bluetooth (TUI)
    blueman         # Bluetooth (GUI - backup)
  ];
}

