{
  inputs,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  voxtype = inputs.voxtype.packages.${system}.onnx-cuda;
in
{
  home.packages = [
    voxtype
    inputs.voxtype-osd.packages.${system}.osd-gtk4
  ];

  # The model is downloaded on first use rather than during a system build.
  xdg.configFile."voxtype/config.toml".text = ''
    # Managed by home-manager — edits here will be overwritten.
    engine = "cohere"

    state_file = "auto"

    # Recording is driven by the Sway Insert binding.
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

  # Starting with Sway ensures WAYLAND_DISPLAY is present for the OSD and text
  # injection.
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
