{ pkgs, ... }:

{
  programs.qutebrowser = {
    enable = true;
    package = pkgs.qutebrowser.override {
      enableWideVine = true;
    };

    # Keep this standby browser close to upstream defaults. These are the few
    # behaviors worth carrying explicitly.
    settings = {
      "auto_save.session" = true;
      "session.lazy_restore" = true;

      "content.autoplay" = false;
      "content.canvas_reading" = false;
      "content.cookies.accept" = "no-unknown-3rdparty";
      "content.javascript.clipboard" = "access-paste";
      "content.notifications.enabled" = false;
      "content.pdfjs" = true;
      "content.prefers_reduced_motion" = true;

      "downloads.location.directory" = "~/Downloads";
      "downloads.location.prompt" = false;

      "editor.command" = [
        "kitty"
        "-e"
        "nvim"
        "{file}"
        "-c"
        "normal {line}G{column0}l"
      ];

      "url.default_page" = "about:blank";
      "url.start_pages" = [ "about:blank" ];
      "url.open_base_url" = true;
      "url.searchengines" = {
        "DEFAULT" = "https://duckduckgo.com/?q={}";
        g = "https://google.com/search?q={}";
        np = "https://search.nixos.org/packages?channel=unstable&query={}";
        no = "https://search.nixos.org/options?channel=unstable&query={}";
        yt = "https://www.youtube.com/results?search_query={}";
      };

      "colors.webpage.darkmode.enabled" = true;
      "colors.webpage.darkmode.policy.images" = "smart";
      "colors.webpage.preferred_color_scheme" = "auto";
    };
  };
}
