{
  pkgs,
  ...
}:

let
  whiteIcons =
    pkgs.runCommand "wlogout-white-icons"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        mkdir -p $out
        for icon in lock logout suspend shutdown reboot; do
          magick "${pkgs.wlogout}/share/wlogout/icons/$icon.png" -fill white -colorize 100% "$out/$icon.png"
        done
      '';
in
{
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
    systemdTargets = [ "sway-session.target" ];

    # TODO: Confirm the dim, lock, display-off, and suspend timeouts.
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
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
        text = "Lock";
        keybind = "l";
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
        border-radius: 0;
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
      #shutdown {
        background-image: image(url("${whiteIcons}/shutdown.png"));
      }
      #reboot {
        background-image: image(url("${whiteIcons}/reboot.png"));
      }
    '';
  };
}
