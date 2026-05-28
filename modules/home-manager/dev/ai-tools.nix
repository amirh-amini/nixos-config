{ pkgs, ... }:

let
  # Package source for AI coding tools.
  # Switch to `pkgs` for nixpkgs versions, or a custom package set.
  ai = pkgs.llm-agents;
in
{
  home.packages = [
    ai.claude-code
    ai.opencode
    ai.codex
    ai.pi
  ];
}
