{
  inputs,
  pkgs,
  ...
}:

let
  # Upstream's ONNX build — carries the Cohere engine (plus parakeet,
  # moonshine, sensevoice, paraformer, dolphin, omnilingual) with the
  # ONNX Runtime already wired via their wrapper.
  voxtype = inputs.voxtype.packages.${pkgs.system}.onnx;
in
{
  home.packages = [
    voxtype
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
    type_delay_ms = 10
  '';

  # Daemon as a user service: starts with the graphical session.
  systemd.user.services.voxtype = {
    Unit = {
      Description = "Voxtype push-to-talk dictation daemon";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${voxtype}/bin/voxtype";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
