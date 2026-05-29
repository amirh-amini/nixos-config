{ pkgs, ... }:
{
  # Per-project environments that auto-activate on `cd` (and deactivate on exit).
  # nix-direnv caches the evaluated devShell and pins a GC root so it survives
  # `nix-collect-garbage` and only re-evaluates when flake.nix/flake.lock change.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # devenv: optional batteries-included per-project environments (uv + CUDA
  # presets, built-in pre-commit hooks, services). Use `devenv init` for
  # batteries-heavy projects; use the `py` flake template (nix flake init -t
  # ~/nixos-config#py) for throwaway tools / minimal trusted surface.
  home.packages = [ pkgs.devenv ];
}