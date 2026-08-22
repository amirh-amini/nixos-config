# BACKLOG

Things postponed, imagined, or waiting for their moment. Nothing here is owed.
When this refactor is done, this file keeps living as the home of future ideas.

## Deferred from the refactor

- **hosts/main/ cosmetics** — rename `configuration.nix` → `default.nix`, rename
  `hardware-configuration.nix` → `hardware.nix`, slim to pure glue. Postponed
  because comfort matters more than symmetry; revisit after Phase 2 proves the
  extraction went smoothly.
- **Delete `templates/py/` from the repo** — currently left untouched on disk;
  decide when templates return to mind.

## Ideas

- **Port liked pieces from Omarchy** (DHH) into this config — explicitly a
  future thing, not part of this refactor.
- **Browser decision** — try zen and/or helium; then re-home the
  qutebrowser/chrome entries properly (`home/qutebrowser.nix`, `default.nix`
  package list).
- **Learn docker properly** — compose, images, and how the self-hosted AI
  observability stack actually fits together.
- **Learn yazi & dolphin deeply** — usage journeys, not config work.
- **Grow `home/agents/` into the full fast lane** — stable/beta flake-input
  channels, `overlays/` packaging skeleton for unpackaged novelties.
- **Project templates** — bring back scaffolds (`templates/`) once creating new
  projects feels repetitive enough to deserve them.
