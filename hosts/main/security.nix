{
  # Desktop authorization, restricted sudo access, and application confinement.
  security = {
    polkit.enable = true;
    soteria.enable = true;
    sudo.execWheelOnly = true;
    apparmor.enable = true;
  };
}
