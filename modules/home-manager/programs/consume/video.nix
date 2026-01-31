{ pkgs, config, lib, ... }:

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
      
      #ytdl-raw-options = "force-ipv4=true";
      ytdl-raw-options = "extractor-args=youtube";
      script-opts = "ytdl_hook-try_ytdl_first=yes";
      #ytdl-raw-options = lib.strings.concatStringsSep ":" [
      #''user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36"''
      #"cookies-from-browser=chrome"
      #];
      ytdl-format = "bestvideo[height<=?1080]+bestaudio/best[height<=?1080]/best";
    };

    scripts = with pkgs.mpvScripts; [
      mpris # Media Player Remote Interfacing Service (media keys support)
      uosc # Modern minimalist UI
      thumbfast # On-the-fly thumbnails
    ];
  };

  home.packages = with pkgs; [
    youtube-tui
    yt-dlp
    ffmpeg
  ];
}
