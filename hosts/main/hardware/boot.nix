{
  boot.loader = {
    timeout = 1;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
      xbootldrMountPoint = "/boot";
    };
  };
}
