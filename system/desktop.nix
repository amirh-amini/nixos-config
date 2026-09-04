{
  ...
}:

{
  # Graphical session stack: ly greeter -> Sway (Wayland).
  # survive as plain packages; xserver stays only because ly may want it —
  # final verdict in Phase D6.
  services.xserver.enable = true;
  services.displayManager.ly = {
    enable = true;
  };
  security.pam.services.ly = {
    text = ''
      auth      include login
      account   include login
      password  include login
      session   include login
    '';
  };

  programs.sway.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.sessionVariables.QT_QPA_PLATFORM = "wayland";

  environment.sessionVariables.WEBKIT_DISABLE_DMABUF_RENDERER = "1";

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };
}
