{
  ...
}:

{
  # Codex desktop (ChatGPT Community build) with the computer-use feature —
  # the whole reason this community packaging exists for us.
  programs.codexDesktopLinux = {
    enable = true;
    computerUseUi.enable = true;
    # cliPackage left default (bundled official codex CLI); revisit if
    # running a second CLI from llm-agents gets annoying.
  };

  # Upstream phones home once per day (anonymous launch counter). Off.
  home.sessionVariables.CODEX_LINUX_DISABLE_USAGE_REPORTING = "1";
}
