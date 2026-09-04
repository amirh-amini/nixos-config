{
  # Codex desktop community Linux build with computer-use support.
  programs.codexDesktopLinux = {
    enable = true;
    computerUseUi.enable = true;
    # TODO: Decide whether the bundled CLI or the llm-agents CLI should be the
    # single Codex command on PATH.
  };

  # Upstream phones home once per day (anonymous launch counter). Off.
  home.sessionVariables.CODEX_LINUX_DISABLE_USAGE_REPORTING = "1";
}
