{ pkgs, ... }:

let
  # Package source for AI coding tools.
  # Switch to `pkgs` for nixpkgs versions, or a custom package set.
  ai = pkgs.llm-agents;
in
{
  home.packages = [
    # Core daily drivers (llm-agents input — numtide, fast-updating)
    ai.claude-code
    ai.opencode
    # ai.codex
    ai.pi
    ai.cursor-agent
    ai.omp
    pkgs.code-cursor-fhs
    pkgs.lmstudio # local LLM runner (kept from former 4now.nix)

    # Second-generation opencode — coexists with v1 above by design
    ai.opencode2

    # Orchestration & support tools
    ai.herdr # tmux-for-agents runtime; sessions survive disconnects
    ai.ccusage # Claude Code token-usage analytics from local logs
    ai.voxtype # voice dictation for the terminal

    # T3 Code — self-packaged in overlays/t3code.nix, both channels by design:
    # stable for daily work, nightly to watch upstream move. Desktop spawns
    # its own backend; CLI is the same engine in your terminal.
    pkgs.t3code-desktop-stable
    pkgs.t3code-desktop-nightly
    pkgs.t3code-cli-stable # bin: t3
    pkgs.t3code-cli-nightly # bin: t3-nightly
  ];
}
