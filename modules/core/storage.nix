{ pkgs, ... }: 

{
  services.udisks2.enable = true;
  services.fstrim.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.snapper = {
    configs = {
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "amirh" ];
        
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        
        TIMELINE_LIMIT_HOURLY = "36";
        TIMELINE_LIMIT_DAILY = "14";
        TIMELINE_LIMIT_WEEKLY = "0";
        TIMELINE_LIMIT_MONTHLY = "0";
        TIMELINE_LIMIT_YEARLY = "0";
      };
    };
  };

  fileSystems = {
    "/" = { options = [ "compress=zstd:3" "noatime" ]; };
    "/home" = { options = [ "compress=zstd:3" "noatime" ]; };
    "/nix" = { options = [ "compress=zstd:3" "noatime" ]; };
    "/var/log" = { options = [ "compress=zstd:3" "noatime" ]; };
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs # Core Btrfs

    dust # disk usage diagram
    btdu # Btrfs space analyzer (TUI)
    
    gptfdisk
    
    # Filesystem Support
    ntfs3g       # NTFS
    exfatprogs   # ExFAT 
    dosfstools   # FAT32 / EFI tools
  ];
}
