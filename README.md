# Living Here

Practical notes for the person who lives on this machine: how updating works,
what storage actually is here, how to clean it safely, and the everyday moves.
The deeper story — why the repo looks the way it does — lives in `PLAN.md`, and
parked ideas live in `BACKLOG.md`.

This file deliberately explains things rather than just listing commands. When a
section tells you _why_ something exists, that context is what lets you
improvise safely later — commands you understand survive being forgotten;
commands you memorized don't.

---

## Mental model first: store, generations, closures

Three concepts explain almost everything about living on NixOS.

**The store (`/nix/store`).** Every package on this machine lives in the store
as an immutable directory whose name contains a hash of its exact contents, like
`/nix/store/x7f3...-firefox-140.0`. "Immutable" is the key word: nothing ever
modifies an installed package in place. Want a different version? That's simply
a different directory sitting next to it. This is why updates can't corrupt
anything and why deleting things is safe: the store only ever grows while
something references it, and garbage collection later removes whatever nothing
references anymore.

**Generations.** A generation is a numbered snapshot of the answer to one
question: "which exact set of packages and configuration files made up my system
at this point in time?" When you rebuild, NixOS creates a new generation and
points at it. Your current one is always reachable as `/run/current-system`. Old
generations keep existing — that's why the boot menu can offer previous ones,
and why rollback is instant: it's just pointing back at an older snapshot, not
reinstalling anything.

**Closures.** A package's closure is everything it needs to run, pulled in
transitively — firefox's closure includes its rendering engines, codecs, and
libraries, which include _their_ dependencies, and so on down to hundreds of
paths. When we say a feature "costs 600 MiB", we mean its closure did. Closures
are also why cleaning disk means removing whole unreferenced subtrees at once,
not individual files.

Git holds the history of the _description_ of your machine (this repo). Nix
holds the history of the _reality_ of your machine (generations). Both histories
are browsable; neither has to be taken on faith.

## Rebuilding the system

After changing anything in this repo, reality must be updated to match. The full
ceremony:

```sh
sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw
```

What actually happens, in order:

1. **Evaluate** — Nix reads the flake and computes exactly which packages and
   files the machine should have. Errors here mean the description is broken;
   nothing on the running system was touched.
2. **Build** — download or build whatever is missing from the store. Still zero
   effect on the running system.
3. **Activate** — point `/etc` and system services at the new set, restart or
   reload whatever units changed. This is the moment reality changes.
4. **Register** — create a new generation and boot menu entry, making it the
   default for future reboots.

The three variants exist because those steps can stop at different points:

- **`switch`** — all four steps. The normal choice when you're confident.
- **`test`** — stops after step 3. Changes are live right now, but no generation
  or boot entry is created, so a reboot returns you to the last switched state.
  Perfect for trying something with an automatic undo waiting at the next
  reboot.
- **`boot`** — skips step 3. Prepares everything and sets it as the next boot
  default without touching the currently running session. Useful for
  kernel/driver changes you'd rather not activate mid-flight.

If typing is the bottleneck, `nh` (installed and pointed at this repo via
`programs.nh.flake`) wraps all of it:

```sh
nh os switch     # = nixos-rebuild switch
nh os test       # = nixos-rebuild test
nh os boot       # = nixos-rebuild boot
```

### So what's the difference between `nix build` and `nixos-rebuild`?

<!-- yeah tell me the commands with nh also what's the diff between nix rebuild
and nix build? -->
<!-- AGENT: answered above and below — `nix build` builds but never
activates; `nixos-rebuild switch/test/boot` build AND act, with the action
chosen by the subcommand. Full explanation in this section. -->

`nix build .#nixosConfigurations.nixos-btw.config.system.build.toplevel` does
steps 1–2 only: it evaluates the config, produces the complete system closure in
the store, and drops a `./result` symlink pointing at it. Nothing is activated,
no generation appears, the running system is untouched. It answers exactly one
question: "does this configuration evaluate and build?" That's why the refactor
used it as the green-light check before every commit.

`nixos-rebuild <action>` internally does the same build and then _acts_ on the
result — activation, generations, boot entries — according to the action you
picked. So the relationship is: **`nix build` constructs, `nixos-rebuild`
constructs and commits**, with `switch` / `test` / `boot` as the three flavors
of committing. During this refactor we lived almost entirely on `nix build`
precisely because construction without commitment is the safe half of the loop.

<!-- farthermore, do not condense and shorten your discriptions. provide clear
readable, pleasent descriptions/explanations -->
<!-- AGENT: understood and applied — this rewrite favors generous,
readable explanations over compressed shorthand, starting with the mental
model section and the step-by-step rebuild walkthrough above. The rest of
the file follows the same voice. -->

## Updating

Everything installed comes from versions pinned in `flake.lock`. Nothing drifts
behind your back: the machine runs exactly what the lockfile says until you
deliberately move it.

Two speeds:

**One tool at a time** — for the fast-moving things (the AI coding tools come
from `llm-agents`, for example):

```sh
nix flake update llm-agents
# then look at what changed, and commit the lockfile if satisfied
git diff flake.lock
sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw
```

Targeted updates are small and reviewable. If a new version breaks a tool,
reverting is `git checkout flake.lock && sudo nixos-rebuild switch ...`.

**Everything at once** — the periodic catch-up:

```sh
nix flake update          # moves every pinned input to latest
git diff flake.lock       # see how far things jumped
sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw
```

Because nixpkgs tracks the _unstable_ channel, occasional breakage is part of
the deal. When something breaks after a full update, the honest options are
pinning that one input back for a few days or just waiting upstream out — both
completely legitimate. What's _not_ needed is panic: the old generation remains
bootable regardless.

Current inputs: `nixpkgs` (unstable), `home-manager`, `llm-agents`,
`nix-vscode-extensions`, `lazyvim-nix`.

## Storage
The filesystem layout, briefly: btrfs everywhere with transparent
compression (`compress=zstd:3`) and `noatime`; `/home` gets hourly snapper
snapshots; the root filesystem gets a weekly integrity scrub; TRIM runs
weekly via fstrim.

Garbage collection is configured to run itself, gently: a weekly timer
prunes generations older than two weeks (always keeping the six most
recent), and the Nix daemon emergency-sweeps unreachable garbage if free
store space ever drops below 20 GiB. You can still clean by hand any time
— the ritual below — but you no longer *have* to remember.

### What actually eats disk

1. `/nix/store` — every package from every generation still referenced.
2. Old system generations themselves (each keeps its packages alive).
3. Home data, plus the overhead snapper snapshots add there.

### Checking usage honestly

```sh
df -h / /home /nix        # filesystem-level free space
dust /home                # interactive tree of what's big in home
btdu /                    # btrfs-aware space explorer (TUI)
btrfs scrub status /      # result of the latest weekly scrub
```

A warning worth internalizing: plain `du` gives misleading numbers on btrfs with
snapshots and compression — files shared between snapshots get counted multiple
times, compressed data gets counted at logical size. Prefer `dust` for quick
orientation and `btdu` when you want the truth.

### Cleaning generations (the careful ritual)

Old generations are your rollback safety net. Cleaning therefore means _pruning
from the oldest end_, never clear-cutting:

```sh
# list them — see how many you've accumulated
sudo nix-env -p /nix/var/nix/profiles/system --list-generations

# delete generations older than two weeks, then reclaim the store space
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +14d
sudo nix-collect-garbage --delete-older-than 14d

# or drop all but the current one (still leaves current untouched):
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
```

With nh, `nh clean all` performs an equivalent sweep and accepts familiar flags
like `--keep-since 14d` and `--keep 5`; check `nh clean --help` for its exact
behavior before trusting it blindly.

Rules of thumb, and the reasoning behind them:

- **Never run `sudo nix-collect-garbage -d` casually.** The `-d` flag deletes
  _all_ old generations — including the boot menu entries that let you escape a
  bad update. It's the one command in this file that can remove your safety net
  in one stroke.
- Always keep at least one known-good generation older than the current one.
  Costs a few GiB; buys a guaranteed way out.
- Space freed by gc shows up immediately — store paths are hard-linked, and gc
  reclaims entire unreferenced subtrees at once.
- Your own user profile can be cleaned without sudo and cannot affect system
  generations: `nix-collect-garbage --delete-older-than 30d`.

### Snapper (home snapshots)

`/home` has an hourly snapshot timeline that keeps roughly 36 hourly and 14
daily snapshots, pruning itself as it goes. Snapshots protect _files_ —
documents, configs, dotfiles — they do nothing for packages.

```sh
snapper -c home list                # what snapshots exist
snapper -c home diff 120..121      # what changed between two of them
snapper -c home undo 120..121      # revert exactly those changes
```

An honest gap, stated plainly: these snapshots live on the same physical disk as
the originals. They protect against mistakes (deleting the wrong file, a bad
tool run) but not against hardware death. Offsite backup of `/home` — or at
minimum of this repo and irreplaceable data — remains an open item tracked in
`BACKLOG.md`.

## Rollback & emergencies (quick card)

- Live regret, system still usable: `sudo nixos-rebuild --rollback switch` —
  instantly repoints to the previous generation, no reboot involved.
- Desktop session dead: `Ctrl+Alt+F3` for a TTY (always available, independent
  of Sway), log in, roll back, then `systemctl restart ly`.
- System won't boot properly: tap **Space rapidly during early boot** — the menu
  timeout is deliberately short (1 second) — and pick the previous generation
  from the list.
- Nuclear option, resets everything to the known-good main branch:
  `git checkout main && sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw`

## Everyday moves

**Adding a package.** Find the bucket under `home/` matching its function
(`code/` for CLI work, `media/`, `files/`, `desk/`, `agents/`…), add it to that
file's `home.packages` list, rebuild. If no bucket fits, pause: either the
package justifies creating a new bucket — a deliberate decision, noted in
PLAN.md — or it doesn't belong on the machine at all.

**Trying software without commitment.** The trial lane needs no repo edits at
all:

```sh
nix run github:some/tool      # fetches, runs, persists nothing
nix shell nixpkgs#foo         # a temporary shell with foo in PATH
uvx some-python-tool          # python tools in isolated environments
```

If a tool survives two weeks of genuine use, promote it properly: declare it in
the right bucket file and write the one-line comment saying _why_ it's there. If
you can't write that line yet, you haven't learned it well enough to own it —
keep trialing. (The full philosophy lives in PLAN.md §7.)

**Finding where something lives.** `grep -r <thing> home/ system/` — since every
file holds one concern and is named for it, a search lands within one file of
the answer, usually in it.

## Repo map (short version)

```
flake.nix     inputs + wiring, nothing else
hosts/main/   this machine: glue + hardware
system/       machine-level modules (base, desktop, services, drivers…)
home/         user-level modules (desk, code, media, files, agents…)
overlays/     self-packaged software (empty right now)
templates/py  python project scaffold
PLAN.md       refactor plan + principles · BACKLOG.md parked ideas
```

_The house stays cozy because putting things away is easy._
