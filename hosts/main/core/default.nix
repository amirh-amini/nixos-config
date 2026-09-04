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

  # TODO: Decide whether to retain this recovery toolkit for repairing the
  # machine when the Home Manager profile is unavailable.
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    pciutils
    lshw
    efibootmgr
  ];
}
