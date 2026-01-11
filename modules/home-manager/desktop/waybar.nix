{ pkgs, lib, config, ... }:

let
  # Sonokai Atlantis Colors
  c_bg      = "#2b2d3a";
  c_fg      = "#e2e2e3";
  c_black   = "#181819";
  c_red     = "#ff6578";
  c_green   = "#9dd274";
  c_yellow  = "#eacb64";
  c_blue    = "#72cce8";
  c_purple  = "#b39df3";
  c_cyan    = "#95e6cb";
  
  # Helper to launch floating TUIs
  floating_term = "${pkgs.kitty}/bin/kitty --class waybar_float";
in
{
  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 22; # Dense
        spacing = 2;
        
        modules-left = [ "sway/workspaces" "tray" ];
        modules-center = [ "clock" ];
        modules-right = [ 
          "sway/language" 
          "network" 
          "bluetooth" 
          "pulseaudio" 
          "group/resources" # Battery is inside here
          "custom/wlogout" 
        ];

        # --- MODULES LEFT ---
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };

        "tray" = {
          icon-size = 13;
          spacing = 5;
        };

        # --- MODULES CENTER ---
        "clock" = {
          format = "{:%a %Y/%m/%d - %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          # Hover for timezones
          tooltip = true; 
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
          # Waybar clock module doesn't natively support "hover to show other timezones"
          # easily in the text, but we can set the calendar to open calcure.
          on-click = "${floating_term} -e calcure";
        };

        # --- MODULES RIGHT ---
        "sway/language" = {
          format = "{short} {variant}";
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
          tooltip-format = "{long}";
        };

        "network" = {
          format-wifi = "{icon}";
          format-ethernet = "󰲝"; # Ethernet Icon
          format-linked = "󰲝 (No IP)";
          format-disconnected = "󰤮"; # Disconnected Icon
          format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ]; # 1, 2, 3, 4 bars
          
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) {signaldBm}dBm {frequency}MHz\nU: {bandwidthUpBytes} D: {bandwidthDownBytes}";
          tooltip-format-ethernet = "{ipaddr}/{cidr}\nU: {bandwidthUpBytes} D: {bandwidthDownBytes}";
          tooltip-format-disconnected = "Disconnected";
          
          on-click = "${floating_term} -e nmtui";
        };

        "bluetooth" = {
          format = ""; # Bluetooth On
          format-disabled = "󰂲"; # Bluetooth Off
          format-connected-battery = " {device_battery_percentage}%";

          format-connected = " {num_connections}";
          
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          
          on-click = "${floating_term} -e bluetui";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-muted = " Muted";
          
          format-icons = {
            headphone = "";
            default = ["󰕿" "󰖀" "󰕾"]; # Low, Mid, High
          };
          
          on-click = "${floating_term} -e pulsemixer";
        };

        # --- GROUP: RESOURCES ---
        "group/resources" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 500;
            children-class = "resources-child";
            transition-left-to-right = false;
          };
          modules = [
            "battery"      # Visible by default
            "cpu"
            "temperature"
            "memory"
            "disk"
          ];
        };

        "battery" = {
          states = {
            # Waybar uses these to set css classes .capacity-10, .capacity-20 etc
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          
          # Standard FontAwesome/Material Battery Icons
          format-icons = ["" "" "" "" ""]; 
          
          on-click = "auto-cpufreq-gtk"; 
        };

        "cpu" = {
          format = " {usage}%";
          on-click = "${floating_term} -e btop";
        };

        "memory" = {
          format = " {used:0.1f}G/{total:0.1f}G";
          on-click = "${floating_term} -e btop";
        };

        "disk" = {
          format = " {specific_used:0.0f}G/{specific_total:0.0f}G";
          unit = "GB";
          on-click = "${floating_term} -e btop";
        };
        
        "temperature" = {
          critical-threshold = 80;
          format = " {temperatureC}°C";
          on-click = "${floating_term} -e btop";
        };

        "custom/wlogout" = {
          format = "";
          on-click = "wlogout";
          tooltip = false;
        };
      };
    };

    # 3. CSS Styling (Sonokai Atlantis)
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", Roboto, Helvetica, Arial, sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: ${c_bg};
        color: ${c_fg};
      }

      /* Workspaces */
      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: ${c_fg};
        border-top: 2px solid transparent;
      }

      #workspaces button.focused {
        color: ${c_green};
        border-top: 2px solid ${c_green};
      }

      #workspaces button.urgent {
        color: ${c_red};
        background-color: ${c_bg};
      }

      #workspaces button:hover {
        background-color: ${c_black};
        color: ${c_cyan};
      }

      /* Base module style */
      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #custom-wlogout,
      #language,
      #bluetooth {
        padding: 0 10px;
        color: ${c_fg};
        background-color: transparent;
      }

      #clock {
        color: ${c_blue};
        font-weight: bold;
      }

      /* Tooltip styling */
      tooltip {
        background: ${c_bg};
        border: 1px solid ${c_blue};
      }
      tooltip label {
        color: ${c_fg};
      }

      /* Network */
      #network.disconnected {
        color: ${c_red};
      }
      #network.ethernet {
        color: ${c_green};
      }
      #network.wifi {
        color: ${c_purple};
      }

      /* Bluetooth */
      #bluetooth.on, #bluetooth.connected {
        color: ${c_blue};
      }
      #bluetooth.off {
        color: #5d5d5d;
      }

      /* Battery Colors - The Gradient Request */
      /* Waybar assigns classes based on %: capacity-10, capacity-20... */
      
      /* < 10% */
      #battery.critical:not(.charging) { 
        color: ${c_red}; 
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      /* 10% - 20% */
      #battery.warning:not(.charging) { color: #ff8f40; } /* Orange-ish */

      /* Mapping closest to your requests */
      /* > 23 (approx 30 class) */
      #battery.capacity-30 { color: #eacb64; } /* Yellow */
      
      /* > 35 (approx 40 class) */
      #battery.capacity-40 { color: #d0d758; } /* Yellow-Green */
      
      /* > 48 (approx 50 class) */
      #battery.capacity-50 { color: #b6e24c; } /* Light Green */
      
      /* > 60 (approx 60 class) */
      #battery.capacity-60 { color: #9dd274; } /* Green */
      
      /* > 73 (approx 70/80 class) */
      #battery.capacity-70 { color: #72cce8; } /* Blue-ish Green */
      #battery.capacity-80 { color: #72cce8; }
      
      /* > 85 (90/100 class) */
      #battery.capacity-90 { color: ${c_green}; }
      #battery.capacity-100 { color: ${c_green}; } 

      /* System Resources Group Drawer */
      #cpu, #memory, #temperature, #disk {
        color: ${c_purple};
      }

      #custom-wlogout {
        color: ${c_red};
        padding-right: 15px;
      }
      
      @keyframes blink {
        to {
          background-color: ${c_red};
          color: ${c_black};
        }
      }
    '';
  };
}
