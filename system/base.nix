{
  pkgs,
  ...
}:

{
  # Base machine identity: locale, user, shells, nix itself.

  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.amirh = {
    isNormalUser = true;
    description = "amirh";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = false;
    flake = "/home/amirh/nixos-config";
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    pciutils
    lshw
    efibootmgr
    nvtopPackages.full
    gvfs # trash/mounts for nautilus & friends without the GNOME session
  ];

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Binary caches beyond cache.nixos.org.
  # cache.numtide.com hosts prebuilt closures for numtide flakes
  # (e.g. llm-agents.nix's omp/bun-cache) so we don't have to build
  # them locally — building omp pulls a large npm tree via fetchurl
  # inside the sandbox, which fails when the host has no IPv6.
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://cache.numtide.com"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
  nixpkgs.config.allowUnfree = true;
}
