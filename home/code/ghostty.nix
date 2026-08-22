{
  ...
}:

{
  # Ghostty terminal — second terminal alongside kitty; minimal start.
  programs.ghostty = {
    enable = true;
    settings = {
      # Native Wayland by default; theme follows later, with use.
    };
  };
}
