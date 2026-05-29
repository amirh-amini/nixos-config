{ pkgs, ... }:
{
  # uv: fast, pip-compatible Python package + venv manager. Why uv over plain pip
  # for the supply-chain goal: it writes a hash-pinned lockfile (uv.lock) and
  # supports a release "cooldown" (`uv pip install --exclude-newer YYYY-MM-DD`)
  # that skips brand-new — possibly compromised — releases. Pip habits transfer:
  # `uv venv`, `uv pip install <pkg>`. Wheels run thanks to nix-ld
  # (../../core/nix-ld.nix). Installs are auto-sandboxed (./sandbox.nix).
  #
  # No global Python on purpose: it would (a) collide with python envs other
  # programs pull into the profile, and (b) defeat the per-project model. uv is
  # a standalone binary; per-project Python comes from the devShell/template
  # (or `uv python install`).
  home.packages = with pkgs; [
    uv
  ];
}