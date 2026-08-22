# Rebuilding the Home

A plan for refactoring this NixOS configuration into something that feels
like a home: intentional, personal, cozy, and fully understood by the one
person who lives in it.

> The goal state: modifying, updating, adding, removing — all comfortable.
> The whole picture fits in one head. Every line earns its place.

---

## 1 · Why

This config became a museum of aspirational selves: an Emacs user who never
was, a Yazi power user who never opened it, a security researcher whose
guarddog was packaged and never run, a screenshots-and-recordings studio.
Each exhibit was plausible. None survived contact with the actual life of
the machine: Sway, fuzzel, keyd, Chrome, sioyek, zsh.

Living inside someone else's intentions — even partly your own past
intentions, even partly an agent's helpfulness — produces exactly one
feeling: discomfort. The cure is subtraction until ownership is total,
then rebuilding what remains to fit in your head.

## 2 · Principles (the constitution, seed form)

These are the rules the final structure must obey. They come from this
conversation, nowhere else.

1. **Comprehension ownership.** Every mechanism is either something you
   wrote or something you consciously adopted and could re-derive.
   Unread code is trusted code; that includes anything an agent produced.
2. **Usage earns existence.** Tools stay because hands use them weekly.
   Ugly-but-used beats beautiful-but-ignored. Git remembers deleted work;
   complexity does not delete itself.
3. **No untracked persistent mutation.** The machine's lasting behavior is
   described by the repo plus nothing else. Experiments live in quarantine
   lanes (§7) until promoted deliberately.
4. **Stock over bespoke.** nixpkgs options before custom machinery. Every
   flake input and every clever mechanism is maintenance debt that comes
   due on update day.
5. **One flake at the root.** Flakes buy pinning and cross-repo
   composition; inside one repo with one host they buy nothing but extra
   lockfiles to audit. Sub-flakes are rejected unless publishing or a
   second host ever becomes real.
6. **Structure serves questions.** Directories are named for intent ("where
   do I change my browser?"), not mechanism. Buckets are coarse and boring.
7. **Aesthetics are functional.** Consistent formatting, calm file layout,
   readable code. Cozy is not decoration; it is what makes maintenance feel
   like tidying your own home instead of servicing a stranger's machine.
8. **Agents are guests.** They propose, you dispose. Nothing enters the
   declared spine without surviving real use. (A fresh CLAUDE.md encoding
   this constitution is itself part of Phase 4.)

## 3 · Target shape

```
flake.nix                # inputs + wiring only — never grows
hosts/main/
  default.nix            # glue: imports + hostname/user/identity
  hardware.nix           # renamed from hardware-configuration.nix

overlays/                # self-packaged things; may sit empty after guarddog dies
templates/py/

system/                  # the machine — root's domain
  base.nix               # locale, time, user, zsh, nix settings, caches, nh
  desktop.nix            # ly, sway enable, pipewire (+ xserver verdict from Phase 3)
  drivers.nix            # gpu, xe initrd          (was core/gpu.nix)
  input.nix              # keyd                    (was core/keyd.nix)
  services.nix           # docker, printing, bluetooth, obs/portals
  power.nix              # unchanged
  storage.nix            # unchanged (light walkthrough only)
  fonts.nix              # unchanged
  security.nix           # * pending interrogation
  dev-support.nix        # * nix-ld, pending interrogation

home/                    # the user — amirh's domain
  default.nix            # imports, identity/stateVersion, dconf, wallpaper, userDirs
  comms.nix              # flat singleton
  qutebrowser.nix        # flat singleton — kept as-is for now (parked)
  desk/
    sway.nix waybar.nix fuzzel.nix pointer.nix screenshot.nix lock.nix*
    # lock = rebuild pile · utils.nix dissolves item-by-item into here & elsewhere
  code/
    git.nix zsh.nix direnv.nix kitty.nix python-tools.nix neovim.nix* vscode.nix*
  agents/
    ai-tools.nix         # future home of the fast lane (§7)
  media/
    video/mpv · sioyek.nix · vimiv.nix · bare packages: spotify, vlc
  files/
    yazi.nix dolphin.nix # learning postponed; nautilus arrives when GNOME dies
```

### Placement rules

| Rule | Meaning |
|---|---|
| One concern per file | filename = the words you would search for |
| Dirs are earned | a directory needs ≥ 2 real files; singletons stay flat |
| No junk drawers | `utils`, `4now`, `misc` cannot exist — items get real homes or die |
| Packages live by function | every package sits in its function's bucket, dissolving `home.packages` |
| flake.nix never grows | hand-packaged code goes to `overlays/` |

## 4 · The ledger

Verdicts reached during the census. Nothing here moves without its commit.

### Corpses — delete, zero sentiment

| Item | Notes |
|---|---|
| emacs | module dir + commented refs + **emacs-overlay input** in flake.nix |
| aria2 | incl. Varia if present |
| sandbox.nix | "I do not want this" |
| screen-recording.nix | confirmed unused |
| voice-recorder.nix | confirmed unused |
| guarddog | pkgs/guarddog.nix + overlay + flake output + references in python-tools |
| GNOME session | `desktopManager.gnome.enable` and friends die; **apps stay** — nautilus → `home/files/`, gedit/gnome-tweaks re-homed; then interrogate whether `services.xserver.enable` survives at all |

### Parked — kept as-is, no guilt

qutebrowser (until zen/helium decision) · yazi · dolphin · storage (light walkthrough)

### Interrogation pile — understand through confrontation, then simplify

nix-ld · security.nix · secrets.nix · docker (real job: self-hosted AI observability; learn later) · ai-tools · xserver question · obs/screen-sharing brokenness (fix-or-flag)

### Rebuild pile — hated but wanted; redone minimal, one at a time

lock.nix · vscode.nix · neovim.nix · utils.nix (dissolve) · 4now.nix (dissolve/delete) · sioyek.nix light cleanup (low priority)

## 5 · Verification discipline

- **Every commit builds green**: `nix build .#nixosConfigurations.nixos-btw.config.system.build.toplevel`
- **Pure-move commits prove purity**: `nix store diff-closures <gen-A> <gen-B>` ≈ empty
- **A bootable generation always exists**: snapper snapshots active, `configurationLimit = 5`; switch at phase checkpoints, build-only between them
- **One concern per commit**, so any breakage bisects trivially

Baseline to capture before touching anything:

```sh
git checkout refactor/layout
nix build .#nixosConfigurations.nixos-btw.config.system.build.toplevel
nix path-info -rSh /run/current-system | sort -k2 -h > /tmp/closure-baseline.txt
```

## 6 · Phases

### Phase 0 — Safety net *(done)*
Branch `refactor/layout` created; mainline untouched. This document written.

### Phase 1 — Corpses
One commit per body, green build between each, diff-closures confirming
nothing else moved. Order: sandbox → screen-recording → voice-recorder →
aria2 → guarddog → emacs → GNOME session (last: biggest, needs the
nautilus/app migration done in the same commit so Files keeps working).

### Phase 2 — Re-homing
Mechanical moves into the target tree. Format pass first (`nixfmt`) as its
own commit so later diffs stay semantic. Then:
1. split inline blocks out of hosts/main/configuration.nix → system/base, desktop, services
2. move core/* → system/* under new names
3. re-home home-manager modules into buckets; dissolve utils.nix and 4now.nix item-by-item; flatten singletons (comms)
4. dissolve home.packages into bucket files by function
5. rename hardware-configuration.nix → hardware.nix; slim hosts/main/default.nix to glue
Green build per step; diff-closures per pure-move step.

### Phase 3 — Interrogation
For each pile item: explain conceptually → test removal → decide keep /
simplify / delete → survivor rewritten simpler, in your words. Includes the
xserver question and the obs portal fix-or-flag. Comprehension through
confrontation, not comments.

### Phase 4 — Constitution on paper
README (what lives where, placement rules) + fresh CLAUDE.md encoding §2
so every future agent session obeys current-you instead of zombie docs.

### Phase 5 — Rebuilds, one at a time
lock → vscode → neovim → ai-tools grows into the fast-lane module.
Boring over clever; sized to fit in your head.

### Phase 6 — Play
yazi/dolphin walkthroughs whenever curiosity strikes. That is joy, not work.

## 7 · The fast lane (two lanes + a gate)

**Trial lane** — no repo changes, ever:

```sh
nix run github:some/tool        # test-drive, nothing persists
uvx some-python-tool            # same, for python things
nix shell nixpkgs#foo           # keep a shell while deciding
```

**Adopted lane** — one flake input per tool used weekly, exposed through
`home/agents/`. Stable and beta channels are two inputs following different
refs. Updates are targeted and deliberate: `nix flake update <tool>`,
glancing at what changed — never blind `--all`.

**The gate.** Promotion is the comprehension event: you type the ten lines,
choose the ref, and write a one-line comment in your own words — why it is
there. If you cannot write the line, you are not ready to promote.
Unpackaged novelties get ~20 boring lines in `overlays/` from a skeleton.
Any tool skipped twice in a row at update time gets asked aloud whether it
is still alive.

## 8 · Rituals that keep it alive

| Ritual | Cadence | Act |
|---|---|---|
| Targeted updates | as needed | `nix flake update <input>`, read what changed |
| Seasonal glance | each season | walk the adopted list: "still mine?" |
| Promotion gate | on adoption | write the lines yourself, write the why |
| Deletion default | always | unsure → delete; git remembers, complexity doesn't |

---

*A home isn't clean once. It's easy to clean.*
