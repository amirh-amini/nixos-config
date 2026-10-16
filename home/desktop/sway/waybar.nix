{
  pkgs,
  ...
}:

let
  background = "#181A1C";
  foreground = "#e2e2e3";
  dim = "#7f849c";
  black = "#181819";

  floatingTerminal = "ghostty --confirm-close-surface=false";

  clockScript = pkgs.writeShellScript "waybar-clock" ''
    main_time=$(date +'%a %Y/%m/%d - %H:%M')
    tehran=$(TZ='Asia/Tehran' date +'%H:%M %a')
    nyc=$(TZ='America/New_York' date +'%H:%M %a')
    utc=$(TZ='Etc/UTC' date +'%H:%M %a')
    echo "{\"text\": \"$main_time\", \"tooltip\": \"Tehran: $tehran\nNYC:    $nyc\nUTC:    $utc\"}"
  '';
in
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 20;
        spacing = 1;

        modules-left = [
          "sway/workspaces"
          "tray"
        ];
        modules-center = [ "custom/clock" ];
        modules-right = [
          "sway/language"
          "custom/sep"
          "network"
          "custom/sep"
          "bluetooth"
          "custom/sep"
          "pulseaudio"
          "custom/sep"
          "group/resources"
          "custom/sep"
          "custom/wlogout"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };

        "tray" = {
          icon-size = 10;
          spacing = 5;
        };

        "custom/clock" = {
          # TODO: Confirm Tehran, New York, and UTC are the useful secondary
          # time zones.
          exec = "${clockScript}";
          return-type = "json";
          interval = 60;
          on-click = "${floatingTerminal} -e calcure";
        };

        "sway/language" = {
          format = "{short} {variant}";
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
          tooltip-format = "{long}";
        };

        "custom/sep" = {
          format = "|";
          tooltip = false;
        };

        "network" = {
          format-wifi = "{icon}";
          format-ethernet = "󰲝";
          format-linked = "󰲝 (No IP)";
          format-disconnected = "󰤮";
          format-icons = [
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];

          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) {signaldBm}dBm {frequency}MHz\nU: {bandwidthUpBytes} D: {bandwidthDownBytes}";
          tooltip-format-ethernet = "{ipaddr}/{cidr}\nU: {bandwidthUpBytes} D: {bandwidthDownBytes}";
          tooltip-format-disconnected = "Disconnected";

          on-click = "${floatingTerminal} -e nmtui";
        };

        "bluetooth" = {
          format = "";
          format-disabled = "󰂲";
          format-connected-battery = " {device_battery_percentage}%";

          format-connected = " {num_connections}";

          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";

          on-click = "${floatingTerminal} -e bluetui";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-muted = "";

          format-icons = {
            headphone = "";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };

          on-click = "${floatingTerminal} -e pulsemixer";
        };

        "group/resources" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 500;
            children-class = "resources-child";
            transition-left-to-right = false;
          };
          modules = [
            "battery"
            "cpu"
            "temperature"
            "memory"
            "disk"
          ];
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";

          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];

          on-click = "auto-cpufreq-gtk";
        };

        "cpu" = {
          format = " {usage}%";
          on-click = "${floatingTerminal} -e btop";
        };

        "memory" = {
          format = " {used:0.1f}G/{total:0.1f}G";
          on-click = "${floatingTerminal} -e btop";
        };

        "disk" = {
          format = " {specific_used:0.0f}G/{specific_total:0.0f}G";
          unit = "GB";
          on-click = "${floatingTerminal} -e btop";
        };

        "temperature" = {
          critical-threshold = 80;
          format = " {temperatureC}°C";
          on-click = "${floatingTerminal} -e btop";
        };

        "custom/wlogout" = {
          format = "";
          on-click = "wlogout";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", Roboto, Helvetica, Arial, sans-serif;
        font-size: 11px;
        min-height: 0;
      }

      window#waybar {
        background-color: ${background};
        color: ${foreground};
      }

      #workspaces button {
        padding: 0 2px;
        background-color: transparent;
        color: ${dim};
        border-top: 2px solid transparent;
      }

      #workspaces button.focused {
        color: ${foreground};
        border-top: 2px solid ${foreground};
      }

      #workspaces button.urgent {
        color: ${background};
        background-color: ${foreground};
      }

      #workspaces button:hover {
        color: ${foreground};
      }

      #custom-sep {
        color: ${foreground};
        opacity: 0.3;
        padding: 0 2px;
      }

      #custom-clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #network,
      #pulseaudio,
      #tray,
      #custom-wlogout,
      #language,
      #bluetooth {
        padding: 0 6px;
        color: ${foreground};
        background-color: transparent;
      }

      tooltip {
        background: ${background};
        border: 1px solid ${foreground};
      }
      tooltip label {
        color: ${foreground};
      }

      #network.disconnected,
      #bluetooth.off,
      #bluetooth.disabled {
        color: ${dim};
      }

      #battery.critical:not(.charging) {
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      @keyframes blink {
        to {
          background-color: ${foreground};
          color: ${black};
        }
      }
    '';
  };
}
