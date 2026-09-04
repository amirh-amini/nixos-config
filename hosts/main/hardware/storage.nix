{ pkgs, ... }:

{
  services = {
    udisks2.enable = true;
    fstrim.enable = true;

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };

    snapper.configs = {
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "amirh" ];

        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        # TODO: Confirm this retention policy: 36 hourly and 14 daily snapshots,
        # with no weekly, monthly, or yearly snapshots.
        TIMELINE_LIMIT_HOURLY = "36";
        TIMELINE_LIMIT_DAILY = "14";
        TIMELINE_LIMIT_WEEKLY = "0";
        TIMELINE_LIMIT_MONTHLY = "0";
        TIMELINE_LIMIT_YEARLY = "0";
      };
    };
  };

  fileSystems = {
    "/" = {
      options = [
        "compress=zstd:3"
        "noatime"
      ];
    };
    "/home" = {
      options = [
        "compress=zstd:3"
        "noatime"
      ];
    };
    "/nix" = {
      options = [
        "compress=zstd:3"
        "noatime"
      ];
    };
    "/var/log" = {
      options = [
        "compress=zstd:3"
        "noatime"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    gptfdisk
    gparted
    ntfs3g
    exfatprogs
    dosfstools
  ];
}
