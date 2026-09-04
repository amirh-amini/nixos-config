{
  imports = [
    ./hardware
    ./core
    ./desktop
    ./services
    ./development.nix
    ./security.nix
    ./home-manager.nix
  ];

  networking.hostName = "nixos-btw";
  system.stateVersion = "25.11";
}
