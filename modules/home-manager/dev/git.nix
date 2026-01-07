{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "amirh-amini";
    userEmail = "169299589+amirh-amini@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}

