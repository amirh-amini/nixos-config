{ pkgs, ... }: 
{
  security.polkit.enable = true;
  security.soteria.enable = true;
}

