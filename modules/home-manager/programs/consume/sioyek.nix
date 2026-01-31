{ pkgs, ... }:

{
  programs.sioyek = {
    enable = true;
    package = pkgs.sioyek;

    config = {
      "background_color" = "0.15 0.15 0.15";
      "dark_mode_background_color" = "0.0 0.0 0.0";
      "dark_mode_contrast" = "0.8";
      "text_highlight_color" = "1.0 1.0 0.0";
      "status_bar_color" = "0.15 0.15 0.15";
      "status_bar_text_color" = "1.0 1.0 1.0";
      
      "startup_commands" = "toggle_visual_scroll;toggle_dark_mode";
      "should_launch_new_window" = "1";
      "prerender_page_count" = "50";
      "default_zoom" = "fit_to_page_width_smart";
      
      "search_url_g" = "https://www.google.com/search?q=";
      "search_url_w" = "https://en.wikipedia.org/w/index.php?search=";
      "middle_click_search_engine" = "g";
      "shift_middle_click_search_engine" = "w";
      
      "show_doc_path" = "1";
      
      "super_fast_search" = "1";
      "case_sensitive_search" = "0";
      
      "collapsed_toc" = "1";
      "create_table_of_contents_if_not_exists" = "1";
      "max_created_toc_size" = "5000";
      #"ruler_mode" = "1";
      #"ruler_padding" = "1.0";
      #"ruler_x_padding" = "5.0";
    };
  };
}
