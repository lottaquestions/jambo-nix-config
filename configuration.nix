# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./v4l2.nix
    # ./osx-kvm.nix
  ];

  # v4l2 = true;
  # osx-kvm = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.grub.useOSProber = true;
  boot.loader.grub.device = "/dev/sda";
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModprobeConfig = "
     options iwlwifi power_save=0
  ";

  networking.hostName = "jambo"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  # networking.hosts = { "insert ip here" = [ "hostname" ]; };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  services.blueman.enable = true;
  services.urxvtd = { enable = true; };

  services.udev.packages = with pkgs; [ android-udev-rules ];
  # Enable Picom composite WM
  # services.picom = {
  #   enable = true;
  #   shadow = true;
  #   opacityRules = [ "100:class_g = 'Firefox' && argb" ];
  # };
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = true;
    # videoDrivers = [ "nvidia" ];
    desktopManager = {
      plasma5.enable = true;
    };
    windowManager = {
      awesome = {
        enable = true;
        luaModules = [ pkgs.luaPackages.luaposix ];
      };
      xmonad = { enable = true; };
    };
    displayManager = {
      sddm.enable = true;
      # defaultSession = "enlightenment";
      sessionCommands = ''
        xrdb "${
          pkgs.writeText "xrdb.conf" ''
            xterm*background:             black
            xterm*foreground:             white
            xterm*vt100.locale:           true
            xterm*vt100.metaSendsEscape:  true

            URxvt.iso14755:               false
            URxvt.iso14755_52:            false

            URxvt.perl-ext-common:        default,matcher,resize-font,url-select,keyboard-select,selection-to-clipboard,fullscreen
            URxvt.transparent:            true
            URxvt.shading:                30

            URxvt.background:             black
            URxvt.foreground:             white

            URxvt.scrollBar:              false
            URxvt.scrollTtyKeypress:      true
            URxvt.scrollTtyOutput:        false
            URxvt.scrollWithBuffer:       false
            URxvt.scrollstyle:            plain
            URxvt.secondaryScroll:        true

            URxvt.colorUL:                #AED210
            URxvt.resize-font.step:       2
            URxvt.matcher.button:         1
            URxvt.url-select.underline:   true

            URxvt.copyCommand:            ${pkgs.xclip}/bin/xclip -i -selection clipboard
            URxvt.pasteCommand:           ${pkgs.xclip}/bin/xclip -o -selection clipboard

            URxvt.keysym.M-c:             perl:clipboard:copy
            URxvt.keysym.M-v:             perl:clipboard:paste

            URxvt.keysym.Shift-Control-V: eval:paste_clipboard
            URxvt.keysym.Shift-Control-C: eval:selection_to_clipboard

            URxvt.keysym.M-Escape:        perl:keyboard-select:activate
            URxvt.keysym.M-s:             perl:keyboard-select:search

            URxvt.keysym.M-u:             perl:url-select:select_next

            URxvt.keysym.C-minus:         resize-font:smaller
            URxvt.keysym.C-plus:          resize-font:bigger
            URxvt.keysym.C-equal:         resize-font:reset
            URxvt.keysym.C-question:      resize-font:show
            URxvt.keysym.C-Down:          resize-font:smaller
            URxvt.keysym.C-Up:            resize-font:bigger

            Xft.antialias:                1
            Xft.autohint:                 0
            Xft.hinting:                  1
            Xft.hintstyle:                hintslight
            Xft.lcdfilter:                lcddefault
            Xft.rgba:                     rgb
          ''
        }"
      '';
    };
  };


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.Enable = "Source,Sink,Media,Socket";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  # 
  users = {
    users = {
      lottaquestions = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "networkmanager" "shadow" ];
      };
    };
    extraUsers = { lottaquestions = { shell = pkgs.fish; }; };
  };

  systemd.user.services = {
    # "udiskie" = {
    #   enable = true;
    #   description = "udiskie to automount removable media";
    #   wantedBy = [ "default.target" ];
    #   path = with pkgs; [
    #     gnome3.adwaita-icon-theme
    #     # gnome3.gnome_themes_standard
    #     udiskie
    #   ];
    #   environment.XDG_DATA_DIRS = "${pkgs.gnome3.adwaita-icon-theme}/share";
    #   serviceConfig.Restart = "always";
    #   serviceConfig.RestartSec = 2;
    #   serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie -a -t -n -F ";
    # };
    "stalonetray" = {
      enable = true;
      description = "A standalone tray";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session-pre.target" ];
      path = with pkgs; [ stalonetray ];
      serviceConfig = {
        Restart = "always";
        RestartSec = 3;
        ExecStart = "${pkgs.stalonetray}/bin/stalonetray";
      };
    };

    "stretchly" = {
      enable = true;
      description = "A break time reminder app";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session-pre.target" ];
      path = with pkgs; [ stretchly ];
      serviceConfig = {
        Restart = "always";
        RestartSec = 3;
        ExecStart = "${pkgs.stretchly}/bin/stretchly";
      };
    };
  };

  nix = {
    settings = {
      trusted-users = [ "lottaquestions" ];
      substituters = [ "https://cache.nixos.org/" ];
      trusted-public-keys = [ ];
      auto-optimise-store = true;
    };
    package  = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      min-free = ${toString (1 * 1024 * 1024 * 1024)}
      max-free = ${toString (5 * 1024 * 1024 * 1024)}
    '';
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
    input-fonts.acceptLicense = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    binutils
    git
    fish
    networkmanagerapplet
    htop
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    input-fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;
  programs.nm-applet.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "tty";
  };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    stateVersion = "22.05"; # Did you read the comment?
    autoUpgrade = {
      enable = true;
      channel = "https://channels.nixos.org/nixos-unstable-small";
      dates = "02:00";
    };
  };
}

