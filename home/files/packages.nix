{
  pkgs,
  ...
}:

{
  # GUI apps around documents and notes — config-less by choice.
  home.packages = with pkgs; [
    nautilus # file manager (GNOME app, session-independent since B7)
    obsidian
    heynote # developer scratchpad — language-blocked buffer notes (Electron, native Wayland via NIXOS_OZONE_WL)
    gedit
  ];
}
