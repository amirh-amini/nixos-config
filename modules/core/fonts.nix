{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      # Monospace
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono

      # Sans-Serif
      ibm-plex

      # Serif
      merriweather
      noto-fonts
      vazir-fonts
      
      # Symbols & Emoji
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
      
      # Icons
      #font-awesome
      #material-design-icons

      # Asian/CJK
      noto-fonts-cjk-sans 
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font" ];
        sansSerif = [ "IBM Plex Sans" ];
        serif = [ "Merriweather" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}

