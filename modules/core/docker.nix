{ pkgs, ... }:
{
  # Rootless Docker: daemon runs as the logged-in user, not root.
  # - No `docker` group (membership there is root-equivalent).
  # - A container escape lands in an unprivileged user, not root.
  # - Doesn't punch holes in the NixOS firewall like rootful Docker does,
  #   so published container ports stay unreachable from outside the machine.
  # Limitation: can't bind ports < 1024 (Laminar uses 5667/8000/8001 — fine).
  virtualisation.docker.rootless = {
    enable = true;
    # Sets DOCKER_HOST for users so `docker` talks to the rootless daemon.
    setSocketVariable = true;
  };
}
