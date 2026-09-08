{
  # Automatic GC disabled (2026-09-08): nothing deletes store paths on its own
  # anymore — run `nh clean` manually, ideally right after a switch when the
  # new generation anchors the fresh closure. Commented lines below restore
  # the automatic cleanup.
  # TODO: research this more before settling — manual-only GC depends on a
  # habit; look into retention alternatives (nh clean with different flags,
  # min-free as emergency valve only, gcroots for expensive closures).
  nix.settings = {
    # min-free = 20 * 1024 * 1024 * 1024;
    # max-free = 50 * 1024 * 1024 * 1024;

    trusted-users = [
      "root"
      "@wheel"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [
      "https://cache.nixos.org/"
      "https://cache.numtide.com"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  systemd.services.nix-daemon = {
    # Keep the desktop responsive during builds (calibrated on 2026-09-08:
    # `0-15 + 1200%` felt responsive, `2-13 + 1000%` felt sluggish — desktop
    # need is ~3 P-cores' worth, so reserve two 5.1 GHz P-cores outright and
    # cap the builders' group budget 2 cores below their allowed capacity).
    # Builders inherit nice 10, so desktop threads also win direct contention.
    # NOTE: changing this block restarts nix-daemon on the next switch —
    # don't switch while an unrelated build is running.
    serviceConfig = {
      AllowedCPUs = "2-15";
      CPUQuota = "1200%";
      Nice = 10;
    };
  };

  programs.nh = {
    enable = true;
    flake = "/home/amirh/nixos-config";
    # Weekly automatic cleanup disabled (2026-09-08) — GC is manual now; see
    # the note on nix.settings above. Uncomment to re-enable:
    # clean = {
    #   enable = true;
    #   dates = "weekly";
    #   extraArgs = "--keep-since 14d --keep 6";
    # };
  };

  nixpkgs.config = {
    allowUnfree = true;

    # TODO: Remove this exception when Logseq no longer requires Electron 39,
    # or remove Logseq if it is not part of the final application set.
    permittedInsecurePackages = [ "electron-39.8.10" ];
  };
}
