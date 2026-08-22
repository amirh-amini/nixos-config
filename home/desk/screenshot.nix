{ pkgs, ... }:

# Wayland/Sway screenshot stack:
#   grim   — capture (full output or geometry)
#   slurp  — interactive region/window selection
#   satty  — annotation editor (pipe target)
# wl-clipboard (wl-copy) is provided in utils.nix.
#
# Keybindings live in sway.nix. Capture flows pipe grim → satty via stdin.
{
  home.packages = with pkgs; [
    grim
    slurp
    satty
  ];

  # satty won't create the save directory itself; ensure it exists.
  home.file."Pictures/Screenshots/.keep".text = "";

  xdg.configFile."satty/config.toml".text = ''
    [general]
    # Copy to clipboard on Enter, just exit on Escape.
    actions-on-enter = ["save-to-clipboard"]
    actions-on-escape = ["exit"]
    # Quit after the action so the editor doesn't linger.
    early-exit = true
    # Match Mako/Tokyo Night theme; wl-copy handles the clipboard.
    copy-command = "wl-copy"
    initial-tool = "brush"
    primary-highlighter = "block"
    corner-roundness = 8
    # Saved screenshots (Ctrl+S) land here with a timestamp.
    output-filename = "${"\${HOME}"}/Pictures/Screenshots/satty-%Y%m%d-%H%M%S.png"
    disable-notifications = false

    [font]
    family = "JetBrainsMono Nerd Font"
    style = "Regular"

    [color-palette]
    palette = [
      "#7aa2f7",
      "#f7768e",
      "#9ece6a",
      "#e0af68",
      "#bb9af7",
      "#c0caf5",
    ]
  '';
}
