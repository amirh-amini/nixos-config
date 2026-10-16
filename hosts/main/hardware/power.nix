{
  services = {
    thermald.enable = true;

    auto-cpufreq = {
      enable = true;

      # TODO: Confirm the 75/90 charge thresholds and aggressive battery/AC
      # profiles match the desired balance of battery health and performance.
      settings = {
        battery = {
          governor = "powersave";
          energy_performance_preference = "power";
          platform_profile = "low-power";
          turbo = "never";
          enable_thresholds = true;
          start_threshold = 75;
          stop_threshold = 90;
        };

        charger = {
          governor = "performance";
          energy_performance_preference = "balance_performance";
          platform_profile = "performance";
          turbo = "auto";
          enable_thresholds = true;
          start_threshold = 75;
          stop_threshold = 90;
        };
      };
    };

    power-profiles-daemon.enable = false;
    tlp.enable = false;
  };
}
