{ pkgs, lib, config, ... }:

let
  # 1. Create a custom package of White Icons
  # This takes the default wlogout icons and forces them to be solid white
  whiteIcons = pkgs.runCommand "wlogout-white-icons" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out
    # List of icons to process
    for icon in lock logout suspend hibernate shutdown reboot; do
      if [ -f "${pkgs.wlogout}/share/wlogout/icons/$icon.png" ]; then
        # -fill white -colorize 100% turns all non-transparent pixels pure white
        convert "${pkgs.wlogout}/share/wlogout/icons/$icon.png" -fill white -colorize 100% "$out/$icon.png"
      else
        echo "Warning: Icon $icon not found"
      fi
    done
  '';
in
{
  home.packages = with pkgs; [
    imagemagick # Needed for the icon generation above
  ];

  programs.swaylock = {
    enable = true;
    settings = {
      color = "181A1C";
      no-unlock-indicator = false;
      show-keyboard-layout = true;
      indicator-caps-lock = true;
      daemonize = true;
      ignore-empty-password = true;
    };
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "sway-session.target";
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f"; 
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
    timeouts = [
      {
        timeout = 180;
        command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 50%-";
        resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -r"; 
      }
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 300;
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
      {
        timeout = 900;
        command = "systemctl suspend";
      }
    ];
  };

  programs.wlogout = {
    enable = true;
    package = pkgs.wlogout;
    
    layout = [
      { 
        label = "lock"; 
        action = "${pkgs.swaylock}/bin/swaylock -f"; 
        text = "Lock"; keybind = "l"; 
      }
      { 
        label = "logout";
        action = "swaymsg exit"; 
        text = "Logout"; 
        keybind = "e";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];

    style = ''
      window {
          background-color: rgba(0, 0, 0, 0.85);
      }

      button {
          background-color: #2c2c2c;
          border: 2px solid #ffffff;
          border-radius: 0px;
          color: #ffffff;
          
          background-repeat: no-repeat;
          background-position: center 25%; 
          background-size: 25%;            
          
          margin: 10px;
          transition: background-color 0.2s ease-in-out;
      }

      button:hover {
          background-color: #444444;
      }

      #lock {
          background-image: image(url("${whiteIcons}/lock.png"));
      }
      #logout {
          background-image: image(url("${whiteIcons}/logout.png"));
      }
      #suspend {
          background-image: image(url("${whiteIcons}/suspend.png"));
      }
      #hibernate {
          background-image: image(url("${whiteIcons}/hibernate.png"));
      }
      #shutdown {
          background-image: image(url("${whiteIcons}/shutdown.png"));
      }
      #reboot {
          background-image: image(url("${whiteIcons}/reboot.png"));
      }
    '';
  };
}
