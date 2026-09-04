{ ... }:
{
  security.polkit.enable = true;
  security.soteria.enable = true;

  security.sudo.execWheelOnly = true;
  security.apparmor.enable = true;

  #security.pam.services.swaylock = {};
}
