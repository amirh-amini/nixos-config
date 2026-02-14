{ pkgs, lib, config, ... }:

let
  cursorTheme = config.home.pointerCursor.name;
  cursorSize = config.home.pointerCursor.size;
in
{
  home.packages = with pkgs; [
    wl-gammactl
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;

    config = {
      input = {
        "type:keyboard" = {
          xkb_layout = "us,ir";
          xkb_options = "grp:alt_shift_toggle";
        };
        "type:touchpad" = {
          dwt = "enabled";              # Disable While Typing
          tap = "enabled";              # Tap to click
          natural_scroll = "enabled";   # scroll direction
        };
      };

      seat = {
        "*" = {
          xcursor_theme = "${cursorTheme} ${toString cursorSize}";
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
      
      #output = {
      #  "*" = { bg = "${../assets/b-413.jpg} fill"; };
      #};

      bars = [ 
        { command = "${pkgs.waybar}/bin/waybar"; } 
      ];

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
    #extraConfig = ''
    #  include ~/.config/sway/outputs
    #'';
  };
  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
  wayland.systemd.target = "sway-session.target";
}

