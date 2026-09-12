{ pkgs, ... }:

let
  ai = pkgs.llm-agents;
in
{
  home.packages = [
    ai.claude-code
    ai.opencode
    pkgs.opencode2
    pkgs.opencode2-desktop
    pkgs.opencode-desktop
    ai.codex
    ai.pi
    ai.cursor-agent
    pkgs.code-cursor-fhs

    pkgs.t3code-desktop-stable
    pkgs.t3code-desktop-nightly
    pkgs.t3code-cli-stable
    pkgs.t3code-cli-nightly
  ];
}
