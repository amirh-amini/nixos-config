{
  # This stays host-owned because the NixOS module creates a dedicated service
  # account, persistent data directory, and hardened system service.
  services.memos = {
    enable = true;
    openFirewall = false;
  };
}
