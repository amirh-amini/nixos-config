{
  pkgs,
  lib,
  config,
  ...
}:

let
  cursorTheme = config.home.pointerCursor.name;
  cursorSize = config.home.pointerCursor.size;
in
{
  imports = [
    ./fuzzel.nix
    ./waybar.nix
    ./lock.nix
    ./screenshot.nix
  ];

  home = {
    pointerCursor = {
      enable = true;
      gtk.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 16;
    };

    packages = [ pkgs.wl-gammactl ];

    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "sway";
      XDG_CURRENT_DESKTOP = "sway";
      # TODO: Verify these application compatibility overrides are still needed.
      SDL_VIDEODRIVER = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

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
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      seat = {
        "*" = {
          xcursor_theme = "${cursorTheme} ${toString cursorSize}";
        };
      };

      modifier = "Mod4";
      terminal = "ghostty";
      menu = "${pkgs.fuzzel}/bin/fuzzel";

      window = {
        titlebar = false;
        border = 1;
        commands = [
          {
            criteria = {
              app_id = "com.gabm.satty";
            };
            command = "floating enable, move position center";
          }
          {
            criteria = {
              app_id = "Heynote";
            };
            command = "floating enable, resize set 1100 800, move position center";
          }
        ]
        ++
          map
            (title: {
              # Ghostty exposes the child application's title as the reliable
              # identifier for these utility windows.
              criteria = {
                title = "^${title}$";
              };
              command = "floating enable, resize set 1000 600, move position center";
            })
            [
              "calcure"
              "nmtui"
              "bluetui"
              "pulsemixer"
              "btop"
            ];
      };

      floating = {
        titlebar = false;
        border = 2;
      };

      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];

      keybindings = lib.mkOptionDefault {
        "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume raise";
        "XF86AudioLowerVolume" = "exec swayosd-client --output-volume lower";
        "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle";
        "XF86AudioMicMute" = "exec swayosd-client --input-volume mute-toggle";

        "XF86MonBrightnessUp" = "exec swayosd-client --brightness raise";
        "XF86MonBrightnessDown" = "exec swayosd-client --brightness lower";

        "Mod4+shift+v" = "exec cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";

        "Insert" = "exec voxtype record toggle";

        "Mod4+Shift+d" = "exec nwg-displays";

        "Print" = "exec grim -g \"$(slurp -d)\" - | satty --filename -";
        "Shift+Print" = "exec grim - | satty --filename -";
      };
    };
  };
  wayland.systemd.target = "sway-session.target";
}
