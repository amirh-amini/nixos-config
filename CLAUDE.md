# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy

```bash
# Rebuild and switch to new configuration (aliased to `update` in zsh)
sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw

# Alternatively, use nh (Nix Helper, configured in this repo)
nh os switch

# Update flake inputs
nix flake update

# Check flake validity
nix flake check
```

The single host is `nixos-btw`. There is only one system configuration.

## Architecture

This is a NixOS flake-based configuration tracking **nixos-unstable**. It uses **home-manager** as a NixOS module (not standalone).

### Flake Inputs
- `nixpkgs` (nixos-unstable)
- `home-manager` (follows nixpkgs)
- `emacs-overlay` (follows nixpkgs) — applied as a nixpkgs overlay

### Module Layout

**Entry point:** `flake.nix` → `hosts/main/configuration.nix` → imports all core modules + home-manager

```
hosts/main/
  configuration.nix    # System config: bootloader, networking, desktop, audio, user
  hardware-configuration.nix

modules/core/          # System-level (imported by configuration.nix)
  gpu.nix              # Intel + NVIDIA hybrid (Prime offload)
  keyd.nix             # Key remapping (alt↔super swap)
  power.nix            # thermald, auto-cpufreq, battery profiles
  fonts.nix            # System font configuration
  storage.nix          # BTRFS, snapper snapshots, fstrim
  security.nix         # Polkit, AppArmor, sudo hardening

modules/home-manager/  # User-level (imported by home.nix)
  home.nix             # Main entry: imports all submodules below
  desktop/             # Sway, Waybar, Fuzzel, screen lock/idle, notifications, file manager
  dev/                 # Zsh, Git, Kitty terminal, misc dev tools (4now.nix)
  programs/            # Emacs (large config), Qutebrowser, communication apps, media (mpv, sioyek)
```

### Key Patterns
- **System vs user separation:** `modules/core/` for NixOS system options, `modules/home-manager/` for home-manager user options. New modules should follow this split.
- **Home-manager uses global pkgs:** `useGlobalPkgs = true` and `useUserPackages = true` — no separate nixpkgs instance for home-manager.
- **Inputs passed via specialArgs:** All flake inputs are available in every module via `inputs` argument.
- **Emacs config uses org-auto-tangle:** The Emacs configuration lives in `modules/home-manager/programs/emacs/config.org` and tangles to `.el` files. The nix module symlinks the config directory.

### Desktop Environment
- **Primary:** Sway (Wayland) via home-manager with Waybar, Fuzzel launcher, Mako notifications
- **Fallback:** GNOME (system-level, mostly for compatibility)
- **Display manager:** Ly
- **Audio:** PipeWire (with ALSA and PulseAudio compatibility)

## Design Philosophy

From `goal.md`: the configuration prioritizes a liberating, deterministic, minimal-maintenance workflow. Security is a top concern (especially supply chain attacks). Avoid overcomplication — every addition should have clear purpose.
