{
  pkgs,
  ...
}:

{
  programs.mpv = {
    enable = true;
    config = {
      force-window = true;
      save-position-on-quit = true;
      save-watch-history = true;
      keep-open = "yes";

      vo = "gpu-next";
      hwdec = "auto-safe";

      osd-bar = "no";
      border = "no";

      ytdl-format = "bestvideo[height<=?1080]+bestaudio/best[height<=?1080]/best";
    };

    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
      thumbfast
    ];
  };

  home.packages = with pkgs; [
    youtube-tui
    yt-dlp
    ffmpeg
  ];
}
