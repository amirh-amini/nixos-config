{ inputs, ... }:

{
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.amirh = import ../../home/default.nix;
  };
}
