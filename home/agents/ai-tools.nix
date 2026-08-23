{ pkgs, ... }:

let
  # Package source for AI coding tools.
  # Switch to `pkgs` for nixpkgs versions, or a custom package set.
  ai = pkgs.llm-agents;
in
{
  # agentsview phones home a daily anonymous "daemon alive" ping — off.
  home.sessionVariables.AGENTSVIEW_TELEMETRY_ENABLED = "0";

  home.packages = [
    # Core daily drivers (llm-agents input — numtide, fast-updating)
    ai.claude-code
    ai.opencode
    ai.codex # OpenAI Codex CLI
    ai.pi
    ai.cursor-agent
    ai.omp
    pkgs.code-cursor-fhs
    pkgs.lmstudio # local LLM runner (kept from former 4now.nix)

    # Second-generation opencode — coexists with v1 above by design
    ai.opencode2

    # Orchestration & support tools
    ai.herdr # tmux-for-agents runtime; sessions survive disconnects
    ai.ccusage # unified usage reports across all agent CLIs (claude/codex/opencode/…)
    ai.voxtype # voice dictation for the terminal
    # Local-first session browser/analytics across every agent's native store.
    # Replaces ccusage for browsing; keep both — ccusage for quick terminal reports.
    ai.agentsview

    # T3 Code — self-packaged in overlays/t3code.nix, both channels by design:
    # stable for daily work, nightly to watch upstream move. Desktop spawns
    # its own backend; CLI is the same engine in your terminal.
    pkgs.t3code-desktop-stable
    pkgs.t3code-desktop-nightly
    pkgs.t3code-cli-stable # bin: t3
    pkgs.t3code-cli-nightly # bin: t3-nightly
  ];
}
