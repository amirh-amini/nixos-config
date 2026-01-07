{ pkgs, config, lib, ... }: 

{
  services.thermald.enable = true;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    
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

    # Use 'ls /sys/class/power_supply/' to find the names.
    # power_supply_ignore_list = [
    # 
    # ];
  };

  services.power-profiles-daemon.enable = false;
  services.tlp.enable = false; 
}

