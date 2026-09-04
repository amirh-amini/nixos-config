{
  inputs,
  pkgs,
  ...
}:

let
  # Upstream's CUDA build — same engines as `onnx`, but ONNX Runtime ships
  # the CUDA execution provider, so Cohere transcribes on the RTX GPU
  # instead of CPU (~2x realtime → target: much faster). Falls back to
  # CPU automatically if the provider fails to initialize.
  system = pkgs.stdenv.hostPlatform.system;
  voxtype = inputs.voxtype.packages.${system}.onnx-cuda;
in
{
  home.packages = [
    voxtype
    # Waveform OSD — the launcher prefers this frontend automatically.
    # Built from the nixpkgs-following twin input (see flake.nix) so it
    # reuses the existing store path instead of the pinned-old GTK world.
    inputs.voxtype-osd.packages.${system}.osd-gtk4
  ];

  # Declarative config; the cohere model (~1.5 GB q4f16) downloads on
  # first use / `voxtype setup model`.
  xdg.configFile."voxtype/config.toml".text = ''
    # Managed by home-manager — edits here will be overwritten.
    engine = "cohere"

    state_file = "auto"

    # Recording is driven by sway keybindings ($mod+v), not the built-in
    # evdev ScrollLock listener.
    [hotkey]
    enabled = false

    [audio]
    device = "default"
    sample_rate = 16000
    max_duration_secs = 60

    [cohere]
    model = "cohere-transcribe-q4f16"
    language = "en"
    on_demand_loading = false

    [output]
    mode = "type"
    fallback_to_clipboard = true
    type_delay_ms = 0
  '';

  # Daemon as a user service: starts with the graphical session.
  # Bound to sway-session.target, NOT graphical-session.target — the fake
  # graphical target fires before sway imports WAYLAND_DISPLAY into the
  # systemd user environment, leaving the daemon unable to reach Wayland
  # (OSD dies, wtype/wl-copy injection fails).
  systemd.user.services.voxtype = {
    Unit = {
      Description = "Voxtype push-to-talk dictation daemon";
      PartOf = [ "sway-session.target" ];
      After = [ "sway-session.target" ];
    };
    Service = {
      ExecStart = "${voxtype}/bin/voxtype";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "sway-session.target" ];
  };
}
