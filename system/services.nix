{
  ...
}:

{
  services.printing.enable = true;

  # Memos, note-taking service — native systemd unit (not a container), data
  # in /var/lib/memos, own memos user/group. Serves on :5230, localhost only
  # (firewall stays closed); add a reverse proxy if it should leave the box.
  services.memos = {
    enable = true;
    openFirewall = false;
  };
}
