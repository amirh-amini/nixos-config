{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../system/drivers.nix
    ../../system/input.nix
    ../../system/power.nix
    ../../system/fonts.nix
    ../../system/storage.nix
    ../../system/security.nix
    ../../system/dev-support.nix
    ../../modules/core/docker.nix
    ../../modules/core/obs.nix
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";
  boot.initrd.kernelModules = [ "xe" ];

  # Home Manager Configuration
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "amirh" = import ../../modules/home-manager/home.nix;
    };
  };

  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  # Desktop Environment
  # NOTE: GNOME *session* removed (B7) — we run Sway via ly. GNOME apps
  # (nautilus, tweaks) survive as plain packages; xserver stays only because
  # ly may want it — final verdict in Phase D6.
  services.xserver.enable = true;
  services.displayManager.ly = {
    enable = true;
  };
  security.pam.services.ly = {
    text = ''
      auth      include login
      account   include login
      password  include login
      session   include login
    '';
  };
  systemd.user.settings.Manager = {
    # Override all user units that depend on WAYLAND_DISPLAY
    # This removes ConditionEnvironment=WAYLAND_DISPLAY for all units
    # and makes them start after sway-session.target
    ConditionEnvironment = "";
    After = "sway-session.target";
    WantedBy = "sway-session.target";
  };

  #Sway Support
  programs.sway.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Services
  services.printing.enable = true;
  services.libinput.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # User Account
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
    #clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/amirh/nixos-config";
  };

  # System Packages
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

  system.stateVersion = "25.11";
}
