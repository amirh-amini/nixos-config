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
- `llm-agents` (follows nixpkgs) — overlay providing AI coding tools (`pkgs.llm-agents`)

In-repo overlay: `pkgs/guarddog.nix` is exposed as `pkgs.guarddog` via a small
overlay in `flake.nix` (also `nix build .#guarddog`). `templates/py` is a flake
template (`nix flake init -t ~/nixos-config#py`).

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
  security.nix         # Polkit (soteria agent), AppArmor, sudo hardening
  nix-ld.nix           # Dynamic-linker shim so prebuilt wheels/binaries run

modules/home-manager/  # User-level (imported by home.nix)
  home.nix             # Main entry: imports all submodules below
  desktop/             # Sway, Waybar, Fuzzel, screen lock/idle, notifications, file manager
  dev/                 # Zsh, Git, Kitty, 4now; supply-chain: direnv.nix (direnv+devenv),
                       #   python-tools.nix (uv + guarddog), sandbox.nix (bwrap), secrets.nix (pass)
  programs/            # Emacs (large config), Qutebrowser, communication apps, media (mpv, sioyek)

pkgs/                  # In-repo package derivations (guarddog.nix)
templates/             # Flake dev-shell starters (py)
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

## Python development & supply-chain workflow

Defense against malicious packages (Shai-Hulud-style worms) is layered. The model:
keep secrets out of plaintext, and sandbox the *install* moment rather than every
run. NixOS already gives hermetic builds + flake.lock pinning; this hardens the
imperative `uv` layer on top.

**Start a project** (per-project env, auto-activated by direnv):
```bash
# minimal (pure-flake, smallest trusted surface)
mkdir myproj && cd myproj && nix flake init -t ~/nixos-config#py && direnv allow
# or batteries-included (uv/CUDA presets, pre-commit hooks, services)
devenv init
```

**Install deps — automatically sandboxed.** `uv add|sync|lock`, `uv pip install`,
`uvx`, and `pipx install` are routed through `safe-install` (bubblewrap): an empty
tmpfs `$HOME` (so `~/.ssh`, tokens, agent sockets are invisible), only the project
dir writable, network on. A malicious post-install script runs with nothing to steal.
- Disable for the shell: `export SC_SANDBOX_INSTALLS=0`
- Bypass once: `command uv add <pkg>`
- Run *untrusted* code with no network at all: `sbx <command>`

**Vet before adding** (GuardDog, hermetic, uses nixpkgs Semgrep):
```bash
guarddog pypi scan <package>        # or: guarddog pypi verify requirements.txt
```

**Secrets — `pass` (GPG-encrypted), never env vars / ~/.zshrc:**
```bash
gpg --quick-generate-key "Name <you@example.com>"   # once
pass init <key-id>                                    # once
pass insert openai                                    # store a secret
# use it, scoped to a project, in that project's .envrc (git-ignored):
#   export OPENAI_API_KEY=$(pass show openai)
```
For git, prefer **SSH** (key in `~/.ssh`) so there is no token to store.

**Deferred (researched, not yet enabled):** JS/TS (pnpm/Deno), CUDA/GPU
(`cache.nixos-cuda.org` + `cudaPackages`), ML model scanning (modelscan/picklescan,
safetensors), agenix, and an nsjail max-isolation profile.

## Design Philosophy

From `goal.md`: the configuration prioritizes a liberating, deterministic, minimal-maintenance workflow. Security is a top concern (especially supply chain attacks). Avoid overcomplication — every addition should have clear purpose.

## Research Rigor (mandatory)

**When this applies:** any task that involves *choosing* something — a tool, package, library, approach, or pattern — OR answering a question where the state of the art may have moved since your training cutoff. It does NOT apply to purely mechanical work in code I already have (renames, refactors, fixing a bug in this repo's own logic), where there is nothing external to research.

When it applies, do **not** settle on a default from prior knowledge. Run an actual discovery process, and treat finding the *best* option — not merely a *working* one — as the deliverable:

1. **Start unseeded.** Your first searches must name NO specific tool/library. They must be capable of surfacing options you have never heard of. Putting your expected answers into the query is confirmation, not research — the bias leaks in at query-formulation, one layer earlier than you think.
2. **Separate the layers.** Decompose the problem first; never compare options that live at different layers of the stack (e.g. a capture tool vs. an annotation editor).
3. **Follow the citation graph.** Every README, issue tracker, and forum thread names competitors, forks, and complaints. Chase those leads recursively. An unfamiliar name is a lead to pursue, not noise to filter out.
4. **Hunt dissatisfaction.** Deliberately search for migration and complaints — "switched away from X", "X alternative", "X broken/abandoned". The best options surface where people express frustration with the obvious ones.
5. **Check liveness.** For each candidate: last commit/release date, open-issue volume, deprecation notices, and nixpkgs availability/packaging.
6. **Saturate, then stop.** Keep searching until new queries stop surfacing new options or new objections. Then explicitly state that you have saturated. Do not stop at the first plausible answer.
7. **Report transparently.** Before recommending, show what you searched, what surfaced, and what you rejected and why. Premature stopping must be visible so it can be challenged.
8. **Defend adversarially.** Assume the user will independently find a better option and you will have to defend why you didn't pick it. Name the angles where your pick could still lose.

Do not write the change until this is done and the user has seen the comparison. Prefer plan mode for the research phase. The user holds an extreme standard here ("I am not satisfied until I know there is no other information left to consume") — match it. The `/rigor` command re-injects this protocol on demand.
