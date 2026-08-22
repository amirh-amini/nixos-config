{
  ...
}:

{
  # Graphical session stack: ly greeter -> Sway (Wayland).

  # NOTE: GNOME *session* removed (B7) — we run Sway via ly. GNOME apps
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

  systemd.user.settings.Manager = {
    # Override all user units that depend on WAYLAND_DISPLAY
    # This removes ConditionEnvironment=WAYLAND_DISPLAY for all units
    # and makes them start after sway-session.target
    ConditionEnvironment = "";
    After = "sway-session.target";
    WantedBy = "sway-session.target";
  };

  programs.sway.enable = true;

  # Make Electron apps (codex-desktop, GitButler, …) run native Wayland
  # instead of falling back to XWayland — fixes blurry upscaled text on
  # scaled displays. Apps that misbehave can still be pinned to X11
  # individually with --ozone-platform=x11.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # VLC's Qt shell: without this hint it runs under XWayland (blurry).
  # Every other Qt app on this machine already picks Wayland on its own,
  # so this is safe globally.
  environment.sessionVariables.QT_QPA_PLATFORM = "wayland";

  # GitButler (Tauri/WebKitGTK): DMABUF rendering corrupts layout on
  # NVIDIA. Disabling it restores correct fonts/layout at minor GPU cost.
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
}
