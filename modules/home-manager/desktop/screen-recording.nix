{ pkgs, ... }:

# Screen recording with wl-screenrec — CLI Wayland recorder, VA-API hardware
# encoding (uses the Intel Arrow Lake iGPU). This is the default for normal
# captures; OBS lives at the system level (modules/core/obs.nix) only for its
# virtual camera.
#
# wl-screenrec has no config file, and by default writes `screenrecord.mp4`
# into the *current directory*. It also probes the low-power VAAPI encoder,
# which Arrow Lake's i915 lacks for H.264 (noisy fallback warning). Wrap it so:
#   * output defaults to ~/Videos/Recordings/<timestamp>.mp4 (unless -f given)
#   * --low-power=off on the default H.264 path (unless --low-power/--codec given)
# Everything else passes straight through, so `wl-screenrec -g "$(slurp)" ...`
# and explicit -f/--codec/--low-power still work exactly as upstream.
let
  wl-screenrec = pkgs.writeShellScriptBin "wl-screenrec" ''
    have_file=0
    have_lp=0
    have_codec=0
    for a in "$@"; do
      case "$a" in
        -f|--filename|--filename=*) have_file=1 ;;
        --low-power|--low-power=*)  have_lp=1 ;;
        --codec|--codec=*)          have_codec=1 ;;
      esac
    done

    # Default H.264 path: skip the unavailable low-power encoder and its warning.
    if [ "$have_lp" -eq 0 ] && [ "$have_codec" -eq 0 ]; then
      set -- --low-power=off "$@"
    fi

    # Save somewhere sensible instead of the current directory.
    if [ "$have_file" -eq 0 ]; then
      mkdir -p "$HOME/Videos/Recordings"
      set -- "$@" -f "$HOME/Videos/Recordings/screenrec-$(date +%Y%m%d-%H%M%S).mp4"
    fi

    exec ${pkgs.wl-screenrec}/bin/wl-screenrec "$@"
  '';
in
{
  home.packages = [ wl-screenrec ];

  # Ensure the target directory exists even before the first recording.
  home.file."Videos/Recordings/.keep".text = "";
}
