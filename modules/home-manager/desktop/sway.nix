{ pkgs, lib, config, ... }:

{
  wayland.windowManager.sway = {
    enable = true;

    config = {
      startup = [
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK"; }
        { command = "systemctl --user stop xdg-desktop-portal xdg-desktop-portal-wlr"; }
        { command = "systemctl --user start sway-session.target"; }
      ];
      
      input = {
        "type:keyboard" = {
          xkb_layout = "us,ir";
          xkb_options = "grp:alt_shift_toggle";
        };
      };

      modifier = "Mod4";
      terminal = "kitty"; 
      menu = "${pkgs.fuzzel}/bin/fuzzel";
      
      window = {
        titlebar = false;
        border = 1;
        commands = [
          {
            criteria = { app_id = "waybar_float"; };
            command = "floating enable, resize set 1000 600, move position center";
          }
        ];
      };
      
      floating = {
        titlebar = false;
        border = 2;
      };
      
      output = {
        "*" = { bg = "#24283b solid_color"; };
      };
      
      input = {
        "type:touchpad" = {
          dwt = "enabled";              # Disable While Typing
          tap = "enabled";              # Tap to click
          natural_scroll = "enabled";   # scroll direction
        };
      };

      bars = [ 
        { command = "${pkgs.waybar}/bin/waybar"; } 
      ];

      # --- NEW BINDINGS ---
      keybindings = lib.mkOptionDefault {
        # Audio Control (SwayOSD)
        "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume raise";
        "XF86AudioLowerVolume" = "exec swayosd-client --output-volume lower";
        "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle";
        "XF86AudioMicMute" = "exec swayosd-client --input-volume mute-toggle";

        # Brightness Control (SwayOSD)
        "XF86MonBrightnessUp" = "exec swayosd-client --brightness raise";
        "XF86MonBrightnessDown" = "exec swayosd-client --brightness lower";

        # Clipboard history (Super+V)
        "Mod4+shift+v" = "exec cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";

        # Display Management (Mod+Shift+d)
        "Mod4+Shift+d" = "exec nwg-displays";
      };
    };

    # Allow nwg-displays to save config to a file sway reads
    extraConfig = ''
      include ~/.config/sway/outputs
    '';
    
    # Environment variables (Keep these from previous step)
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };
}

