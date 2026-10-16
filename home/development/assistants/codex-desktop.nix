{
  # Codex desktop community Linux build.
  programs.codexDesktopLinux = {
    enable = true;
    # TODO: Re-enable once ilysenko/codex-desktop-linux#1591 is merged. Its
    # patch emits invalid JS against ChatGPT 26.1013.31256 (duplicate builder
    # parameter), so the app never opens a window. Computer use has also
    # never worked on this machine.
    computerUseUi.enable = false;
    # TODO: Decide whether the bundled CLI or the llm-agents CLI should be the
    # single Codex command on PATH.
  };

  # Upstream phones home once per day (anonymous launch counter). Off.
  home.sessionVariables.CODEX_LINUX_DISABLE_USAGE_REPORTING = "1";
}
