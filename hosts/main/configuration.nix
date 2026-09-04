{
  inputs,
  pkgs,
  ...
}:

{
  # Host glue. Everything else lives in ../../system/ (machine) and
  # ../../home/ (user).

  imports = [
    ./hardware-configuration.nix
    ../../system/base.nix
    ../../system/desktop.nix
    ../../system/services.nix
    ./graphics.nix
    ../../system/input.nix
    ./power.nix
    ../../system/fonts.nix
    ./storage.nix
    ../../system/security.nix
    ../../system/dev-support.nix
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
    # Safety net: if HM needs to manage a path that already exists as a
    # plain file (e.g. imperative browser-default settings), move it aside
    # instead of failing activation.
    backupFileExtension = "hm-backup";
    users = {
      "amirh" = import ../../home/default.nix;
    };
  };

  system.stateVersion = "25.11";
}
