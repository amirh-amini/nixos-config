{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    enableZshIntegration = true;

    extraPackages = with pkgs; [
      file
      fd
      ripgrep
      fzf
      zoxide
      jq
      poppler-utils
      ffmpeg
      p7zip
      imagemagick
      resvg
      chafa
      wl-clipboard
      mediainfo
      exiftool
      zip
      unzip
    ];

    plugins = {
      git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
        settings.order = 1500;
      };
      smart-enter = pkgs.yaziPlugins.smart-enter;
      smart-paste = pkgs.yaziPlugins.smart-paste;
      smart-filter = pkgs.yaziPlugins.smart-filter;
      jump-to-char = pkgs.yaziPlugins.jump-to-char;
      chmod = pkgs.yaziPlugins.chmod;
      compress = pkgs.yaziPlugins.compress;
    };

    settings = {
      opener = {
        edit = [
          {
            run = "\${EDITOR:-nvim} %s";
            block = true;
            desc = "$EDITOR";
            for = "unix";
          }
        ];
        play = [
          {
            run = "mpv %s";
            orphan = true;
            desc = "mpv";
            for = "linux";
          }
          {
            run = ''mediainfo %s1; echo "Press enter to exit"; read _'';
            block = true;
            desc = "Show media info";
            for = "unix";
          }
        ];
        view = [
          {
            run = "vimiv %s";
            orphan = true;
            desc = "vimiv";
            for = "linux";
          }
        ];
        pdf = [
          {
            run = "sioyek %s1";
            orphan = true;
            desc = "sioyek";
            for = "linux";
          }
        ];
        open = [
          {
            run = "xdg-open %s1";
            desc = "Default application";
            for = "linux";
          }
        ];
        reveal = [
          {
            run = "xdg-open %d1";
            desc = "Open containing directory";
            for = "linux";
          }
          {
            run = ''clear; exiftool %s1; echo "Press enter to exit"; read _'';
            block = true;
            desc = "Show EXIF";
            for = "unix";
          }
        ];
        extract = [
          {
            run = "ya pub extract --list %s";
            desc = "Extract here";
          }
        ];
      };

      open.prepend_rules = [
        {
          mime = "image/*";
          use = [
            "view"
            "open"
            "reveal"
          ];
        }
        {
          mime = "{audio,video}/*";
          use = [
            "play"
            "reveal"
          ];
        }
        {
          mime = "application/pdf";
          use = [
            "pdf"
            "open"
            "reveal"
          ];
        }
      ];

      plugin.prepend_fetchers = [
        {
          id = "git";
          url = "*";
          run = "git";
          group = "git";
        }
        {
          id = "git";
          url = "*/";
          run = "git";
          group = "git";
        }
      ];
    };

    keymap.mgr.prepend_keymap = [
      {
        on = "<Enter>";
        run = "plugin smart-enter";
        desc = "Open file or enter directory";
      }
      {
        on = "l";
        run = "plugin smart-enter";
        desc = "Open file or enter directory";
      }
      {
        on = "p";
        run = "plugin smart-paste";
        desc = "Paste into hovered directory";
      }
      {
        on = "F";
        run = "plugin smart-filter";
        desc = "Smart filter";
      }
      {
        on = "f";
        run = "plugin jump-to-char";
        desc = "Jump to character";
      }
      {
        on = "M";
        run = "plugin chmod";
        desc = "Change permissions";
      }
      {
        on = "Z";
        run = "plugin compress";
        desc = "Compress selection";
      }
    ];
  };
}
