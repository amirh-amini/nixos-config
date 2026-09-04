{
  pkgs,
  ...
}:

{
  imports = [ ./nix.nix ];

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

  # Small set of tools useful even when the user environment is unavailable.
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
}
