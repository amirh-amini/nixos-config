{
  ...
}:

{
  # System-level services.

  services.printing.enable = true;
  services.libinput.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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

  # OBS Studio, system-level — needed specifically for the virtual camera.
  # `enableVirtualCamera` loads the v4l2loopback kernel module and writes the
  # modprobe options (devices=1, video_nr=1, card_label="OBS Cam",
  # exclusive_caps=1) plus polkit access so OBS can start the virtual webcam
  # that browsers/Zoom/etc. consume.
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };
}
