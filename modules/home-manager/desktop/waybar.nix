{ pkgs, lib, config, ... }:

let
  # Monochrome Colors (Sonokai-based Greys)
  #c_bg      = "#2b2d3a";  # Dark Grey Background
  c_bg      = "#181A1C";
  c_fg      = "#e2e2e3";  # White-ish Foreground
  c_dim     = "#7f849c";  # Dim Grey (for disabled/disconnected states)
  c_black   = "#181819";

  # Helper to launch floating TUIs
  floating_term = "${pkgs.kitty}/bin/kitty --class waybar_float";
  
  clock_script = pkgs.writeShellScript "waybar-clock" ''
    # 1. Get the main label (Local Time)
    main_time=$(date +'%a %Y/%m/%d - %H:%M')
    
    # 2. Get other timezones
    # You can add more here. Format: %H:%M is Time, %a is Day (e.g., Sat)
    tehran=$(TZ='Asia/Tehran' date +'%H:%M %a')
    nyc=$(TZ='America/New_York' date +'%H:%M %a')
    utc=$(TZ='Etc/UTC' date +'%H:%M %a')
    
    # 3. Output JSON with tooltip
    # \n creates a new line in the tooltip
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
        height = 20; # Dense
        spacing = 1;
        
        modules-left = [ "sway/workspaces" "custom/recorder" "tray" ];
        modules-center = [ "custom/clock" ];
        modules-right = [ 
          "sway/language"  "custom/sep"
          "network"  "custom/sep"
          "bluetooth" "custom/sep" 
          "pulseaudio" "custom/sep"
          "group/resources" "custom/sep"
          "custom/wlogout" 
        ];

        # --- MODULES LEFT ---
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };

        "tray" = {
          icon-size = 10;
          spacing = 5;
        };

        # Voice recorder indicator (scripts in desktop/voice-recorder.nix).
        # Invisible when idle; red mic + timer while recording. `signal = 8`
        # matches the RTMIN+8 nudge voice-record sends for instant updates;
        # the 1s interval keeps the timer ticking and is a fallback.
        "custom/recorder" = {
          exec = "voice-record-status";
          return-type = "json";
          interval = 1;
          signal = 8;
          format = "{}";
          on-click = "voice-record";        # left-click: stop
          on-click-right = "voice-library"; # right-click: open library
        };

        "custom/clock" = {
          exec = "${clock_script}";
          return-type = "json";
          interval = 60; # Update every minute
          on-click = "${floating_term} -e calcure";
        };

        # --- MODULES RIGHT ---
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
          format-muted = "";
          
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
        font-size: 11px; /* Dense size */
        min-height: 0;
      }

      window#waybar {
        background-color: ${c_bg};
        color: ${c_fg};
      }

      /* Workspaces */
      #workspaces button {
        padding: 0 2px;
        background-color: transparent;
        color: ${c_dim}; /* Inactive workspaces are dim */
        border-top: 2px solid transparent;
      }

      #workspaces button.focused {
        color: ${c_fg};
        border-top: 2px solid ${c_fg}; /* White line for focus */
      }

      #workspaces button.urgent {
        color: ${c_bg};
        background-color: ${c_fg}; /* Inverted for urgency */
      }

      #workspaces button:hover {
        color: ${c_fg};
      }
      
      #custom-sep {
        color: ${c_fg};
        opacity: 0.3;
        padding: 0 2px; /* Very tight padding to keep it dense */
      }

      /* Module Styling */
      #clock,
      #custom-clock,
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
      #custom-recorder,
      #bluetooth {
        padding: 0 6px;
        color: ${c_fg};
        background-color: transparent;
      }

      /* Voice recorder: red + pulse while recording (idle = empty/invisible) */
      #custom-recorder.recording {
        color: #f7768e;
        animation-name: recpulse;
        animation-duration: 1s;
        animation-timing-function: ease-in-out;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      @keyframes recpulse {
        to { opacity: 0.35; }
      }

      /* Tooltips */
      tooltip {
        background: ${c_bg};
        border: 1px solid ${c_fg};
      }
      tooltip label {
        color: ${c_fg};
      }

      /* Dim states for Network & Bluetooth */
      #network.disconnected,
      #bluetooth.off,
      #bluetooth.disabled {
        color: ${c_dim};
      }

      #battery.critical:not(.charging) {
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      /* Critical Blink Animation (White to Black) */
      @keyframes blink {
        to {
          background-color: ${c_fg};
          color: ${c_black};
        }
      }
    '';
  };
}
