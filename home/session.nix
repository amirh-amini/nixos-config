{ pkgs, ... }:

{
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      background-color = "#24283b";
      border-color = "#7aa2f7";
      text-color = "#c0caf5";
      border-radius = 5;
      border-size = 2;
    };
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  services.swayosd.enable = true;

  # Session hardware UX: audio control, bluetooth, display management.
  home.packages = with pkgs; [
    wl-clipboard
    nwg-displays
    pulsemixer # Audio mixer (TUI)
    pamixer # Audio control (CLI for keys)
    pwvucontrol # Audio control (GUI - backup)
    bluetui # Bluetooth (TUI)
    blueman # Bluetooth (GUI - backup)
  ];
}
