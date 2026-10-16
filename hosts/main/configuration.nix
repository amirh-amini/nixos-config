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
  # TODO: Choose a permanent hostname. Changing it is safe in this repository,
  # but network peers and SSH aliases may remember the old name.
  networking.hostName = "nixos-btw";
  system.stateVersion = "25.11";
}
