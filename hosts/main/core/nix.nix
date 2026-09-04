{
  # Trigger automatic garbage collection before the store exhausts disk space.
  nix.settings = {
    min-free = 20 * 1024 * 1024 * 1024;
    max-free = 50 * 1024 * 1024 * 1024;

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

  programs.nh = {
    enable = true;
    flake = "/home/amirh/nixos-config";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 6";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;

    # TODO: Remove this exception when Logseq no longer requires Electron 39,
    # or remove Logseq if it is not part of the final application set.
    permittedInsecurePackages = [ "electron-39.8.10" ];
  };
}
