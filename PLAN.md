# Rebuilding the Home — Transition Plan

Part I is context, kept short. Part II is the plan: numbered steps, each with
exact actions, verification commands, and a done-criterion. Steps are executed
in order; nothing is improvised mid-flight — surprises get added to this
document first, then executed.

> Goal state: modifying, updating, adding, removing — all comfortable. The whole
> picture fits in one head. Every line earns its place.

---

# Part I · Context

## Why

The config became a museum of aspirational selves — Emacs user, Yazi power user,
security researcher with an unrun guarddog, recordings studio. None survived
contact with the actual life of the machine. The cure is subtraction until
ownership is total, then rebuilding what remains to fit in your head.

## Principles

1. **Comprehension ownership** — every mechanism written by you or consciously
   adopted; unread code is trusted code.
2. **Usage earns existence** — ugly-but-used beats beautiful-but-ignored.
3. **No untracked persistent mutation** — experiments live in quarantine lanes
   until promoted deliberately.
4. **Stock over bespoke** — nixpkgs options first; every input and clever
   mechanism is maintenance debt.
5. **One flake at the root** — no sub-flakes without a second host or
   publishing.
6. **Structure serves questions** — directories named by intent; coarse, boring
   buckets; dirs need ≥ 2 real files; junk drawers forbidden; packages live by
   function.
7. **Aesthetics are functional** — formatted code, wrapped prose, no tables in
   markdown docs, cozy layout.
8. **Agents are guests** — propose, don't dispose; a fresh CLAUDE.md comes in
   Phase E.

## Ledger

**Corpses:** sandbox · screen-recording · voice-recorder · aria2 (+ Varia; ⚠
Mullvad coupling, see B4) · guarddog (pkg + overlay + flake output + comments) ·
emacs (+ emacs-overlay input) · GNOME session (apps stay).

**Parked:** qutebrowser · yazi · dolphin · storage (light walkthrough).

**Interrogation:** nix-ld · security.nix · secrets.nix · docker · ai-tools ·
xserver question · obs screen-sharing (fix-or-flag).

**Rebuild pile:** lock · vscode · neovim · utils (dissolve) · 4now (dissolve) ·
sioyek light cleanup.

**Deferred ideas:** live in `BACKLOG.md`.

## Target shape

```
flake.nix                # inputs + wiring only — never grows

hosts/main/
  configuration.nix          # glue + identity; inline blocks migrate out
                             #   once (C3); nothing else here moves
  hardware-configuration.nix # generated; untouched

overlays/                    # self-packaged things (empty after B5)

system/                      # the machine
  base.nix                   # locale, time, user, zsh, nix settings, caches
  desktop.nix                # ly, sway, pipewire, portals (+xserver verdict, D)
  drivers.nix                # gpu (was core/gpu.nix)
  input.nix                  # keyd (was core/keyd.nix)
  services.nix               # docker, printing, bluetooth, obs remainder
  power.nix  storage.nix  fonts.nix
  security.nix*  dev-support.nix*        (* interrogation)

home/                        # the user
  default.nix            # imports, identity, dconf, wallpaper, userDirs
  comms.nix  qutebrowser.nix  secrets.nix     # flat singletons
  desk/    sway waybar fuzzel pointer screenshot lock*   (* rebuild)
  code/    git zsh direnv kitty python-tools neovim* vscode*
  agents/  ai-tools.nix       # grows into fast lane (Phase F)
  media/   video.nix sioyek.nix vimiv.nix + bare: spotify, vlc
  files/   yazi.nix dolphin.nix (+ nautilus after B7)
```

---

# Part II · The Plan

## Operating rules for every step

- One step = one commit. Message pattern: `<step-id>: <summary>` (e.g.
  `B5: remove guarddog packaging`).
- Build check (never skipped):
  `nix build .#nixosConfigurations.nixos-btw.config.system.build.toplevel`
- Purity check for move-only steps — keep the previous build around and compare:
  ```sh
  mv result result-prev && nix build <toplevel> \
    && nix store diff-closures ./result-prev ./result
  ```
  Expected: empty. Any package entering/leaving must be explained.
- The running system switches only at phase checkpoints:
  `sudo nixos-rebuild test --flake .#nixos-btw` Rollback if wrong: boot menu
  previous generation, or `sudo nixos-rebuild --rollback switch`.
- ⚠ marks a decision needed from you _before_ the step runs.
- Surprises found mid-step stop the step; the plan gets amended first.

## Phase A — Baseline

**A1 — capture ground truth.** Do: on `refactor/layout`,
`nix path-info -rSh /run/current-system | sort -k2 -h > /tmp/closure-baseline.txt`;
record current generation number
(`nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1`).
Done when: file exists; `git status` clean; branch correct.

## Phase B — Corpses

Each step: delete file(s) + remove every import/reference + build green +
diff-closures shows exactly the removed packages leaving.

**B1 — sandbox.nix.** Do: `git rm modules/home-manager/dev/sandbox.nix`; drop
its import line in `home.nix`; fix the comment in `dev/python-tools.nix` that
mentions auto-sandboxing (textual only). Verify: `rg -i sandbox` → no functional
hits. Done when: build green; uv still present in closure.

**B2 — screen-recording.nix.** Do: `git rm .../desktop/screen-recording.nix`;
drop import in `home.nix`. Check: `rg -i 'screen-record|wf-recorder'` for stray
bindings in sway/waybar configs; strip if present. Done when: build green;
closure loses wf-recorder-class packages.

**B3 — voice-recorder.nix.** Do: `git rm .../desktop/voice-recorder.nix`; drop
import in `home.nix`. Check: `rg -n mpv_float sway.nix waybar.nix` — git history
shows dedicated window-rule tuning for it; strip those rules if they exist. Done
when: build green.

**B4 — aria2 + Varia. ⚠ decision first: you use Mullvad VPN?**
`programs/collect/aria2.nix` silently enables `programs.mullvad-vpn`.

- If YES: move that one line into `desktop/utils.nix`'s successor (or
  `home/comms.nix`) within this commit, then delete `collect/`.
- If NO: delete outright. Do: `git rm -r modules/home-manager/programs/collect`;
  drop import. Done when: build green; aria2/varia leave closure; Mullvad
  verdict recorded here.

**B5 — guarddog everywhere.** Do: `git rm pkgs/guarddog.nix`; in `flake.nix`
remove the `guarddogOverlay` let-binding, its entry in `nixpkgs.overlays`, and
the `packages.${system}.guarddog` output; in `dev/python-tools.nix` remove
`guarddog` from packages and rewrite the comment to be about uv only; fix the
stale GuardDog comment in `vscode.nix`. Verify: `rg -ri guarddog` → zero hits
repo-wide. Done when: build green; guarddog leaves closure; flake eval unchanged
otherwise (`nix flake show` sane).

**B6 — emacs.** Do: `git rm -r modules/home-manager/programs/emacs`; in
`home.nix` delete the disabled-import comment line and commented
`programs.emacs.enable`; in `flake.nix` remove the `emacs-overlay` input and its
overlay entry. Verify: `rg -i emacs` → zero hits. Done when: build green;
emacs + its deps leave closure (large shrink — record size delta vs baseline).

**B7 — GNOME session.** Do in `hosts/main/configuration.nix`: remove
`services.xserver.desktopManager.gnome.enable` (keep `services.xserver.enable` —
the ly module needs it; final verdict is D6). Add, temporarily in
`home.packages`, `nautilus` (moves to `home/files/` in C5) plus `gvfs` in
`environment.systemPackages` so trash/mounts work without the GNOME session.
Switch checkpoint: `test`-switch, log into Sway, verify: Sway session fine,
Files opens, trash works, audio works. Done when: switched generation boots to
usable Sway; closure shrinks by GNOME-scale GBs (record delta).

## Phase C — Re-homing

Sub-phase order matters: format first, then pure moves, then dissolutions.

**C1 — format pass.** Do: `nix run nixpkgs#nixfmt-rfc-style -- .` (or find+xargs
equivalent) over all tracked `.nix` files, own commit, no semantic edits. Done
when: build green; diff-closures vs pre-commit empty; subsequent diffs are
semantic.

_*C2 — core/* → system/_ (pure moves).** Do:
`git mv modules/core/<f> system/<new>` per mapping — gpu→drivers.nix,
keyd→input.nix, others keep names (power, storage, fonts, security);
nix-ld.nix→dev-support.nix. Rewrite import paths in
`hosts/main/configuration.nix`. Done when: `modules/core/` gone; build green;
purity check empty.

**C3 — split configuration.nix inline blocks.** Do: create `system/base.nix`
(locale, timezone, users.amirh, zsh, nix settings incl. caches/substituters, nh,
allowUnfree) and `system/desktop.nix` (ly + pam, pipewire stack, sway enable,
the systemd user-manager tweak, xserver remnants) and `system/services.nix`
(printing, libinput, bluetooth, obs content folded in — read obs.nix and place
portal bits in desktop.nix, rest here, then delete it). Boot, hostname, hardware
import, home-manager wiring stay in configuration.nix. Done when:
configuration.nix reads as glue (~60 lines); build green; purity check empty.

**C4 — home dirs scaffold + bulk moves (pure).** Do: `git mv` per mapping —
desktop/* → `home/desk/` (same names);
dev/git,zsh,direnv,kitty,python-tools,neovim,vscode → `home/code/`;
dev/secrets.nix → `home/secrets.nix`; dev/ai-tools.nix →
`home/agents/ai-tools.nix`; programs/qutebrowser.nix → `home/qutebrowser.nix`;
programs/communicate.nix → `home/comms.nix`;
programs/consume/{sioyek,vimiv,video}.nix → `home/media/`. Rewrite all imports
in `home/default.nix`. Remove emptied dirs. Done when: old dirs gone; build
green; purity check empty.

**C5 — dissolutions (semantic; expect small closure deltas).**

- **utils.nix**: read it; each item either moves to a desk/ file by function or
  dies with a stated reason. File deleted.
- **4now.nix** ⚠ three decisions: `antigravity-fhs` (keep anywhere?), `lmstudio`
  (used?), `pdftk` (needed?). `code-cursor-fhs` is dropped as a duplicate
  (ai-tools declares it). Then file deleted.
- **home.packages dissolved by function**: ripgrep fd bat fzf htop btop
  fastfetch tree zip unzip tmux zellij → `code/`; spotify vlc → `media/`;
  obsidian gedit → `files/`; calcure → `comms.nix`; gnome-tweaks → `desk/`;
  firefox google-chrome alacritty ⚠ (alacritty vs kitty? browsers parked) → hold
  in `default.nix` under an explicit `# parked` section. `home.packages` list
  disappears from default.nix. Done when: default.nix has no grab-bag; every
  package lives by function; build green; closure delta explained line-by-line.

**C6 — sweep.** Verify: `rg -n 'modules/(core|home-manager)'` → zero hits; full
diff-closures against `/tmp/closure-baseline.txt` reviewed; every difference
traced to a named step. Switch checkpoint: `test`-switch + Sway smoke test (keyd
remap, fuzzel, screenshot, audio, Files).

## Phase D — Interrogation (guided sessions, not scripts)

Per item, fixed ritual: I explain conceptually what it does and why it exists →
we test removing it (build + diff-closures) → you rule keep / simplify / delete
→ survivor rewritten simpler, in your words, own commit.

Sessions: **D1** nix-ld · **D2** security.nix · **D3** secrets.nix (pinentry
included) · **D4** docker · **D5** storage light walkthrough · **D6** xserver
question (does anything still need X? if no: delete xserver/gnome leftovers) ·
**D7** obs screen-sharing fix-or-flag · **D8** ai-tools → design the real
fast-lane shape (stable/beta inputs, update ritual) — spec written into PLAN
appendix before implementing in F.

## Phase E — Constitution on paper

**E1 — README.md**: what lives where, placement rules, common tasks ("add a
package", "update one tool", "try something risky"). **E2 — CLAUDE.md**: encode
Part I principles + operating rules + the no-tables/prettier doc conventions, so
future agent sessions obey current-you instead of zombie docs.

## Phase F — Rebuilds, one at a time

Order: **F1** lock.nix → **F2** vscode.nix → **F3** neovim.nix → **F4**
agents/fast-lane implementation per D8 spec. Each begins with a five-line spec
(purpose, options used, what's deliberately absent) appended here and approved
before any code. Boring over clever; sized to fit in your head.

## Phase G — Play

Yazi/dolphin walkthroughs whenever curiosity strikes. Joy, not work.

---

## Rituals that keep it alive

- **Targeted updates** — as needed · `nix flake update <input>`, read what
  changed.
- **Seasonal glance** — each season · walk the adopted list: "still mine?"
- **Promotion gate** — on adoption · write the lines yourself, write the why;
  trial via `nix run` / `uvx`, never repo edits for experiments.
- **Deletion default** — always · unsure → delete; git remembers, complexity
  doesn't.

_A home isn't clean once. It's easy to clean._
