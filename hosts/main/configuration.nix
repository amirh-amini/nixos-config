{ config, pkgs, inputs, ... }:
  
{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/core/gpu.nix 
      ../../modules/core/keyd.nix
      ../../modules/core/power.nix
      ../../modules/core/fonts.nix
      ../../modules/core/storage.nix
      ../../modules/core/security.nix
      ../../modules/core/nix-ld.nix
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

  # Desktop Environment (Gnome)
  services.xserver.enable = true;
  #services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
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
  systemd.user.extraConfig = ''
    # Override all user units that depend on WAYLAND_DISPLAY
    # This removes ConditionEnvironment=WAYLAND_DISPLAY for all units
    # and makes them start after sway-session.target
    [Unit]
    ConditionEnvironment= 
    After=sway-session.target
    WantedBy=sway-session.target
  '';

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
    extraGroups = [ "networkmanager" "wheel" "video" ];
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
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
