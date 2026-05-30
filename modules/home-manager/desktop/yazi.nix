{ pkgs, ... }:

# =============================================================================
# Yazi — blazing-fast terminal file manager (Rust, async I/O)
# Docs: https://yazi-rs.github.io   |   Version target: nixos-unstable (v26.x)
#
# DESIGN NOTES (read me)
# ----------------------
# • EVERY yazi.toml option is written out explicitly below = its upstream
#   default, annotated with its alternatives, so you can consciously choose
#   each value (your request: nothing left implicit).
# • Plugins are DECLARATIVE via pkgs.yaziPlugins.* — these are built from the
#   SAME nixpkgs revision as `pkgs.yazi`, so they are always version-matched.
#   This sidesteps the usual "plugins only work on yazi HEAD" breakage. Do NOT
#   use `ya pkg` (imperative) — it fights this declarative model.
# • A small recommended set of plugins is ENABLED. The FULL menu of optional
#   plugins (with copy-paste enable snippets) is in the big comment block near
#   the bottom — pick individually by un-commenting.
# • Image preview = Kitty graphics protocol (auto-detected; you run Kitty).
#   `chafa` is installed as a graceful ASCII fallback for Alacritty/others.
# • Keymap is ADDITIVE (`prepend_keymap`) — yazi's ~150 defaults stay intact,
#   so future upstream keybindings still reach you (minimal-maintenance). Only
#   custom + plugin bindings are declared. Full default list:
#   https://yazi-rs.github.io/docs/configuration/keymap
# • THEME is intentionally OMITTED (you're minimalist about color): no
#   theme.toml, no status-bar plugin (yatline/yaziline/starship). git.yazi's
#   theme keys are all optional, so git status still works with zero theming.
# • Dolphin (desktop/file-manager.nix) is untouched — this only ADDS yazi.
# =============================================================================

{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;

    # `y` wrapper: on quit, cd your shell into yazi's last directory.
    shellWrapperName = "y";
    enableZshIntegration = true;

    # ---- External tools yazi shells out to (added to yazi's PATH ONLY, ------
    # ---- never your global env). Each line = the feature it unlocks. -------
    extraPackages = with pkgs; [
      file                 # REQUIRED: file-type detection
      fd                   # file-name search  (key: s)
      ripgrep              # file-content search  (key: s, via rg)
      fzf                  # fuzzy subtree jump  (built-in; key: <C-s>)
      zoxide               # frecency jump  (built-in; key: z)  (needs fzf)
      jq                   # JSON preview
      poppler-utils        # PDF preview
      ffmpeg               # video thumbnails
      p7zip                # archive extract + preview (7zz)  + compress plugin
      imagemagick          # HEIC / JPEG-XL / font preview  (>=7.1.1)
      resvg                # SVG preview
      chafa                # ASCII image fallback outside Kitty  (>=1.16)
      wl-clipboard         # Wayland clipboard (so `copy path` works under Sway)
      mediainfo            # "Media info" opener action for audio/video
      exiftool             # "Show EXIF" opener action on reveal
      zip                  # compress plugin (zip archives)
      unzip
    ];

    # ---- Plugins (ENABLED set). Optional menu is at the bottom. ------------
    # `package` only          -> linked, invoked via keymap `plugin <name>`.
    # `{ setup = true; ... }`  -> also emits `require("<name>"):setup(...)`.
    plugins = {
      # git status as a linemode column (fetcher + setup; theme keys optional).
      git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
        settings = { order = 1500; };
      };
      # one key to open a file OR enter a directory (replaces default enter/open).
      smart-enter = pkgs.yaziPlugins.smart-enter;
      # paste into the hovered directory, or CWD if hovering a file.
      smart-paste = pkgs.yaziPlugins.smart-paste;
      # filter that auto-enters a unique match and keeps filtering.
      smart-filter = pkgs.yaziPlugins.smart-filter;
      # vim-like f<char>: jump to next file starting with a typed char.
      jump-to-char = pkgs.yaziPlugins.jump-to-char;
      # chmod the selection via a prompt.
      chmod = pkgs.yaziPlugins.chmod;
      # compress the selection into an archive (zip/tar/7z/…). Needs p7zip/zip.
      compress = pkgs.yaziPlugins.compress;
    };

    # =====================================================================
    # yazi.toml  — every option explicit (= upstream default). Choose each.
    # =====================================================================
    settings = {

      # ----------------------------- [mgr] -----------------------------
      mgr = {
        ratio          = [ 1 4 3 ];          # column widths: parent | current | preview
        sort_by        = "alphabetical";     # none|mtime|btime|extension|alphabetical|natural|size|random
        sort_sensitive = false;              # case-sensitive sort
        sort_reverse   = false;              # reverse order
        sort_dir_first = true;               # directories before files
        sort_translit  = false;              # transliterate non-ASCII before sorting (é -> e)
        sort_fallback  = "alphabetical";     # tiebreaker when sort_by ties (same value set)
        linemode       = "none";             # extra column: none|size|btime|mtime|permissions|owner
        show_hidden    = false;              # show dotfiles
        show_symlink   = true;               # append "-> target" after symlinks
        scrolloff      = 5;                  # rows kept visible above/below the cursor
        mouse_events   = [ "click" "scroll" "drag" ];  # also available: "touch" "move"
      };

      # --------------------------- [preview] ---------------------------
      preview = {
        wrap            = "no";              # soft-wrap text preview: yes|no
        tab_size        = 2;                 # tab width in text preview
        max_width       = 600;               # image preview max width  (px)
        max_height      = 900;               # image preview max height (px)
        cache_dir       = "";                # "" = $XDG_CACHE_HOME/yazi
        image_delay     = 30;                # ms debounce before drawing an image (anti-flicker on scroll)
        image_filter    = "triangle";        # downscaling: nearest|triangle|catmull-rom|lanczos3 (quality ->)
        image_quality   = 75;                # precache JPEG quality 50..90
        ueberzug_scale  = 1;                 # (Überzug++ only; unused under Kitty)
        ueberzug_offset = [ 0 0 0 0 ];       # (Überzug++ only) x y w h cell offset
      };

      # ---------------------------- [opener] ---------------------------
      # Named openers, wired to YOUR apps. Placeholders: %s = selected files,
      # %s1 = first selected, %d1 = first dir, %S/%D = … . block=run in TUI &
      # wait; orphan=detach from yazi so quitting yazi won't kill it.
      opener = {
        edit = [
          { run = "\${EDITOR:-nvim} %s"; block = true; desc = "$EDITOR (neovim)"; for = "unix"; }
        ];
        play = [   # audio + video -> mpv (you have programs.mpv)
          { run = "mpv %s"; orphan = true; desc = "mpv"; for = "linux"; }
          { run = "mediainfo %s1; echo \"Press enter to exit\"; read _"; block = true; desc = "Show media info"; for = "unix"; }
        ];
        view = [ { run = "vimiv %s"; orphan = true; desc = "vimiv"; for = "linux"; } ];  # images
        pdf  = [ { run = "sioyek %s1"; orphan = true; desc = "sioyek"; for = "linux"; } ]; # PDFs
        open = [ { run = "xdg-open %s1"; desc = "xdg-open (default app)"; for = "linux"; } ]; # generic fallback
        reveal = [
          { run = "xdg-open %d1"; desc = "Open containing dir"; for = "linux"; }
          { run = "clear; exiftool %s1; echo \"Press enter to exit\"; read _"; desc = "Show EXIF"; for = "unix"; block = true; }
        ];
        extract = [ { run = "ya pub extract --list %s"; desc = "Extract here"; } ];
      };

      # ----------------------------- [open] ----------------------------
      # PREPEND rules (kept ABOVE yazi's defaults). Route mimes to the openers
      # above. First-listed opener is the default; press `o` to pick others.
      open = {
        prepend_rules = [
          { mime = "image/*";          use = [ "view" "open" "reveal" ]; }
          { mime = "{audio,video}/*";  use = [ "play" "reveal" ]; }
          { mime = "application/pdf";  use = [ "pdf" "open" "reveal" ]; }
        ];
        # To REPLACE all rules instead of prepending, define `rules = [ … ]`.
        # Default rules (for reference) live in yazi's preset; leaving them on.
      };

      # ---------------------------- [plugin] ---------------------------
      # PREPEND plugin rules (kept above defaults). These fetchers feed the
      # `git` plugin (harmless if you remove the git plugin above).
      plugin = {
        prepend_fetchers = [
          { id = "git"; url = "*";  run = "git"; group = "git"; }
          { id = "git"; url = "*/"; run = "git"; group = "git"; }
        ];
        # prepend_previewers / prepend_preloaders / prepend_spotters live here
        # too — the optional-plugins menu below shows exactly what to add.
      };

      # ----------------------------- [tasks] ---------------------------
      tasks = {
        file_workers    = 3;            # parallel file ops (copy/move/delete)
        plugin_workers  = 5;            # parallel plugin tasks
        fetch_workers   = 5;            # parallel fetchers (mime, git, …)
        preload_workers = 2;            # parallel preloaders (thumbnails)
        process_workers = 5;            # parallel spawned processes
        bizarre_retry   = 3;            # retries for flaky operations
        image_alloc     = 536870912;    # max RAM per image decode (bytes) = 512 MiB
        image_bound     = [ 10000 10000 ]; # max image dimensions decoded (w h, px)
        suppress_preload = false;       # hide preload tasks from the task list
      };

      # ----------------------------- [input] ---------------------------
      # cursor_blink is the only behavioural toggle; the rest is popup geometry
      # (title / origin / [x y w h]). Cosmetic — safe to leave at defaults.
      input = {
        cursor_blink = false;
        cd_title     = "Change directory:";          cd_origin     = "top-center"; cd_offset     = [ 0 2 50 3 ];
        create_title = [ "Create:" "Create (dir):" ]; create_origin = "top-center"; create_offset = [ 0 2 50 3 ];
        rename_title = "Rename:";                     rename_origin = "hovered";    rename_offset = [ 0 1 50 3 ];
        filter_title = "Filter:";                     filter_origin = "top-center"; filter_offset = [ 0 2 50 3 ];
        find_title   = [ "Find next:" "Find previous:" ]; find_origin = "top-center"; find_offset = [ 0 2 50 3 ];
        search_title = "Search via {n}:";             search_origin = "top-center"; search_offset = [ 0 2 50 3 ];
        shell_title  = [ "Shell:" "Shell (block):" ]; shell_origin  = "top-center"; shell_offset  = [ 0 2 50 3 ];
      };

      # ---------------------------- [confirm] --------------------------
      # Confirmation popups (title/body/geometry). {n}=count, {s}=plural 's'.
      confirm = {
        trash_title     = "Trash {n} selected file{s}?";              trash_origin   = "center"; trash_offset   = [ 0 0 70 20 ];
        delete_title    = "Permanently delete {n} selected file{s}?"; delete_origin  = "center"; delete_offset  = [ 0 0 70 20 ];
        overwrite_title = "Overwrite file?"; overwrite_body = "Will overwrite the following file:"; overwrite_origin = "center"; overwrite_offset = [ 0 0 50 15 ];
        quit_title      = "Quit?"; quit_body = "There are unfinished tasks, quit anyway?"; quit_origin = "center"; quit_offset = [ 0 0 50 15 ];
      };

      # ----------------------------- [pick] ----------------------------
      # The "Open with:" chooser popup (shown by the `o` key).
      pick = {
        open_title  = "Open with:";
        open_origin = "hovered";
        open_offset = [ 0 1 50 7 ];
      };

      # ----------------------------- [which] ---------------------------
      # The key-hint cheatsheet popup shown after a prefix key.
      which = {
        sort_by        = "none";   # none|key|desc
        sort_sensitive = false;
        sort_reverse   = false;
        sort_translit  = false;
      };

      # ------------------------------ [log] ----------------------------
      log = { enabled = false; };   # write ~/.local/state/yazi/yazi.log for debugging
    };

    # =====================================================================
    # keymap.toml — ADDITIVE. Custom + plugin bindings only (defaults kept).
    # `on` = key (string) or chord (list). Override note: bindings below
    # shadow yazi's default for that key (intended where marked).
    # =====================================================================
    keymap = {
      mgr.prepend_keymap = [
        # --- plugin bindings (only do something if the plugin is enabled) ---
        { on = "<Enter>";     run = "plugin smart-enter";  desc = "Open file / enter dir"; }   # overrides default enter
        { on = "l";           run = "plugin smart-enter";  desc = "Open file / enter dir"; }   # overrides default enter
        { on = "p";           run = "plugin smart-paste";  desc = "Paste into hovered dir"; }  # overrides default paste
        { on = "F";           run = "plugin smart-filter"; desc = "Smart filter"; }
        { on = "f";           run = "plugin jump-to-char"; desc = "Jump to char"; }
        { on = "M";           run = "plugin chmod";        desc = "chmod selection"; }
        { on = "Z";           run = "plugin compress";     desc = "Compress selection"; }

        # --- a couple of QoL examples (un-comment / edit to taste) ---
        # { on = [ "g" "c" ]; run = "cd ~/nixos-config"; desc = "Go: nixos-config"; }
        # { on = [ "g" "d" ]; run = "cd ~/Downloads";    desc = "Go: Downloads"; }
        # { on = "!";          run = ''shell "$SHELL" --block''; desc = "Open shell here"; }
      ];
    };
  };

  # ===========================================================================
  # OPTIONAL PLUGINS — the rest of the ecosystem, version-matched in nixpkgs.
  # Pick individually: add to `plugins = { … }` above (and the keymap/settings
  # noted). All are `pkgs.yaziPlugins.<name>` unless flagged "(not in nixpkgs)".
  # ---------------------------------------------------------------------------
  # UI / NAV
  #   full-border   eye-candy rounded pane borders.
  #                 plugins: full-border = { package = pkgs.yaziPlugins.full-border;
  #                          setup = true; settings.type = lib.generators.mkLuaInline "ui.Border.ROUNDED"; };
  #   toggle-pane   show/hide/maximize a pane.  keymap: plugin toggle-pane max-preview
  #   relative-motions  vim counts (3j, 5k).  plugins: { package=…; setup=true; settings = { show_numbers="relative_absolute"; show_motion=true; }; }
  #   bypass        skip dirs that contain a single sub-dir.  keymap: plugin bypass
  #
  # PREVIEWERS  (each needs a settings.plugin.prepend_previewers entry)
  #   mediainfo     rich audio/video/image metadata (deps: mediainfo, ffmpeg).
  #   ouch          archive preview via ouch (dep: ouch) — alt to built-in 7z.
  #   piper         pipe ANY shell cmd as previewer (e.g. markdown via glow/bat).
  #   duckdb        CSV/TSV/JSON/Parquet as tables (dep: duckdb) — handy for data.
  #   rich-preview  markdown/json/csv via rich-cli (dep: rich-cli).
  #   miller        CSV/TSV/JSON via mlr (dep: miller).
  #   lsar          list archive contents via lsar (dep: unar).
  #   glow          markdown via glow — DEPRECATED upstream in favour of piper.
  #
  # FILES / FS
  #   diff          diff hovered vs selected -> patch (dep: diffutils).  keymap: plugin diff
  #   restore       undo/restore trashed files.  keymap: plugin restore
  #   recycle-bin   browse/restore the trash (overlaps restore — pick one).
  #   mount         disk mount/unmount/eject manager (dep: udisks2).  keymap: plugin mount
  #   sshfs         mount remote dirs over SSH (dep: sshfs).
  #   gvfs          mount MTP/SMB/SFTP/NFS/Google-Drive (dep: gvfs).
  #   time-travel   browse BTRFS/ZFS snapshots in place — RELEVANT: you run
  #                 BTRFS + snapper.  keymap: plugin time-travel
  #   sudo          run privileged file ops (dep: sudo; you have sudo hardening).
  #   convert       image format conversion via magick.  keymap: plugin convert
  #   drag          drag-and-drop into GUI apps via ripdrag (dep: ripdrag).
  #   dupes         find duplicate files (dep: jdupes).
  #
  # CLIPBOARD (Wayland)
  #   wl-clipboard  copy the file OBJECT (not just path) to the Wayland
  #                 clipboard, to paste into GUI apps.  keymap: plugin wl-clipboard
  #
  # MISC
  #   bookmarks     vi-like persistent marks (m/').  setup = true.
  #   projects      save/restore tab+cwd sessions.   setup = true.
  #   mime-ext      faster mime detection by extension (trades some accuracy).
  #                 add to settings.plugin.prepend_fetchers.
  #   lazygit / githead   lazygit popup / p10k-style git header.
  #   yaziline      (not in nixpkgs) minimal status line — would need a manual derivation.
  # ===========================================================================
}
