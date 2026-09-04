{ pkgs, ... }:

let
  ai = pkgs.llm-agents;
in
{
  home.sessionVariables.AGENTSVIEW_TELEMETRY_ENABLED = "0";

  home.packages = [
    ai.herdr
    ai.ccusage
    ai.agentsview

    # TODO: Configure CLIProxyAPI as a user service or remove it.
    ai.cli-proxy-api
  ];
}
