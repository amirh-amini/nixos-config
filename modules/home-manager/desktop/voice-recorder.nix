{ pkgs, ... }:

# Voice memo recorder — small scripting around tools already on the system.
#   ffmpeg  : capture from the PipeWire mic (via the pulse compat layer) and
#             encode straight to Opus (voice-optimised, ~tens of KB/min).
#   fuzzel  : pick a past recording (same pattern as the cliphist clipboard menu).
#   mpv     : play it back (audio only).
#   waybar  : a custom/recorder module shows a red mic while recording.
#
# Three commands are exposed on PATH so sway (keybinds) and waybar (module/clicks)
# can call them by name:
#   voice-record         toggle recording (start / stop+finalise)
#   voice-library        fuzzel list of recordings -> play in mpv
#   voice-record-status  waybar JSON (recording state); refreshed via RTMIN+8
#
# Recordings land in ~/Recordings/Voice/voice-<timestamp>.opus. State (pid +
# start time) lives in $XDG_RUNTIME_DIR so it's wiped on logout.
let
  dir = "$HOME/Recordings/Voice";
  pidfile = "\${XDG_RUNTIME_DIR:-/tmp}/voice-record.pid";
  metafile = "\${XDG_RUNTIME_DIR:-/tmp}/voice-record.meta";
  waybarSignal = "8"; # must match `signal` in the custom/recorder waybar module

  ffmpeg = "${pkgs.ffmpeg}/bin/ffmpeg";
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
  mpv = "${pkgs.mpv}/bin/mpv";
  kitty = "${pkgs.kitty}/bin/kitty";
  pkill = "${pkgs.procps}/bin/pkill";
  notify = "${pkgs.libnotify}/bin/notify-send";

  recordingActive = ''[ -f "${pidfile}" ] && kill -0 "$(cat "${pidfile}" 2>/dev/null)" 2>/dev/null'';
  refreshWaybar = ''${pkill} -RTMIN+${waybarSignal} waybar 2>/dev/null || true'';

  voice-record = pkgs.writeShellScriptBin "voice-record" ''
    set -eu

    if ${recordingActive}; then
      # --- stop: SIGINT lets ffmpeg flush the Opus trailer (valid file) ---
      pid=$(cat "${pidfile}")
      kill -INT "$pid" 2>/dev/null || true
      for _ in 1 2 3 4 5; do kill -0 "$pid" 2>/dev/null || break; sleep 0.2; done
      file=$(sed -n 1p "${metafile}" 2>/dev/null || true)
      rm -f "${pidfile}" "${metafile}"
      ${refreshWaybar}
      ${notify} -a Voice "Recording saved" "''${file##*/}" || true
    else
      # --- start: mono Opus is plenty for speech and keeps the library small ---
      mkdir -p "${dir}"
      file="${dir}/voice-$(date +%Y%m%d-%H%M%S).opus"
      ${ffmpeg} -hide_banner -loglevel error -f pulse -i default \
        -ac 1 -c:a libopus -b:a 48k "$file" >/dev/null 2>&1 &
      pid=$!
      echo "$pid" > "${pidfile}"
      { echo "$file"; date +%s; } > "${metafile}"
      ${refreshWaybar}
      ${notify} -a Voice "Recording started" "''${file##*/}" || true
    fi
  '';

  voice-library = pkgs.writeShellScriptBin "voice-library" ''
    set -eu
    mkdir -p "${dir}"
    sel=$(cd "${dir}" && ls -1t *.opus 2>/dev/null | ${fuzzel} --dmenu --prompt "voice  " || true)
    [ -n "''${sel:-}" ] || exit 0
    # Play inside a floating kitty (waybar_float rule -> float+center) so mpv's
    # terminal UI is visible and its keys work. Playback controls:
    #   Space    pause / resume
    #   <- / ->  seek -/+ 5s
    #   Up / Dn  seek -/+ 1min
    #   [ / ]    slow down / speed up
    #   9 / 0    volume down / up
    #   q        quit (closes the window)
    exec ${kitty} --class waybar_float -e \
      ${mpv} --no-video --force-window=no --term-osd-bar "${dir}/$sel"
  '';

  voice-record-status = pkgs.writeShellScriptBin "voice-record-status" ''
    if ${recordingActive}; then
      name=$(sed -n 1p "${metafile}" 2>/dev/null || true)
      start=$(sed -n 2p "${metafile}" 2>/dev/null || true)
      el=""
      if [ -n "''${start:-}" ]; then
        d=$(( $(date +%s) - start ))
        el=$(printf '%02d:%02d' $((d/60)) $((d%60)))
      fi
      printf '{"text":"  %s","class":"recording","tooltip":"● Recording %s"}\n' "$el" "''${name##*/}"
    else
      printf '{"text":"","class":"idle","tooltip":""}\n'
    fi
  '';
in
{
  home.packages = [
    voice-record
    voice-library
    voice-record-status
    pkgs.libnotify # provides notify-send (mako is the daemon, but the CLI wasn't installed)
  ];

  # Ensure the library directory exists before the first recording.
  home.file."Recordings/Voice/.keep".text = "";
}
