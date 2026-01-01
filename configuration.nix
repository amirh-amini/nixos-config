{ config, lib, pkgs, ... }:

{
  imports =
	[
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set boot loader mount points
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

  # Host name
  networking.hostName = "nixos-btw";
  
  # Enable network
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  #boot.kernelParams = [
  #  "nvidia-drm.modeset=1"
  #];

  hardware.graphics = {enable = true;};
  
  services.xserver.videoDrivers = [ 
    "modesetting"
    "nvidia" 
  ];

  hardware.nvidia = {
    
    #
    modesetting.enable = true;
    
    # 
    powerManagement.enable = true;
    
    #
    powerManagement.finegrained = true;

    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      
      offload = {
        enable = true;
	      enableOffloadCmd = true;
       };
      
      #  
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    
    };
  };
  
  # High-res boot
  boot.initrd.kernelModules = [ "xe" ];

  # Offload video decoding/encoding to the Intel GPU
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  # Power management
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;

  # Enable Gnome
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Gnome Configguration
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
	      accent-color = "blue";
	    };
	  };
  }];

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
   };

  # Enable touchpad support
  services.libinput.enable = true;

  # Define user
   users.users.amirh = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanger" "video" ];
   };

  programs.firefox.enable = true;
  programs.neovim.enable = true;
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "amirh-amini";
        email = "169299589+amirh-amini@users.noreply.github.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
     vim
     tmux
     zellij
     vscode
     neovim
     gedit
     alacritty
     kitty
     obsidian
     
     spotify
     vlc
     firefox
     google-chrome

     curl
     unzip
     zip
     zsh     
     
     htop
     btop
     lshw
     ripgrep
     fd
     bat
     fzf
     efibootmgr
     nvtopPackages.full    
     wget
     tree
     neofetch  
     gnome-tweaks
   ];

  environment.shells = with pkgs; [ zsh ];

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "25.11";

}

