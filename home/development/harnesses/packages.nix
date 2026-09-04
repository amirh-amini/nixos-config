{ pkgs, ... }:

let
  ai = pkgs.llm-agents;
in
{
  home.sessionVariables.AGENTSVIEW_TELEMETRY_ENABLED = "0";

  home.packages = [
    ai.claude-code
    ai.opencode
    ai.codex
    ai.pi
    ai.cursor-agent
    ai.omp
    pkgs.code-cursor-fhs
    pkgs.lmstudio

    # TODO: Decide whether both OpenCode generations remain useful.
    pkgs.opencode2

    ai.herdr
    ai.ccusage
    ai.agentsview

    # TODO: Configure CLIProxyAPI as a user service or remove it.
    ai.cli-proxy-api

    # TODO: Decide whether keeping stable and nightly T3 builds is useful.
    pkgs.t3code-desktop-stable
    pkgs.t3code-desktop-nightly
    pkgs.t3code-cli-stable
    pkgs.t3code-cli-nightly
  ];
}
