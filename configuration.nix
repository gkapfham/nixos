# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Add customized configuration for Framework 13 AMD laptop
      <nixos-hardware/framework/13-inch/7040-amd>
      # Include the results of the hardware scan
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Linux kernel; latest kernel is currently not sufficient
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Define a custom linux kernel for support of AMD Ryzen 7040 CPU
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_6.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
            url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
            sha256 = "sha256-DOaOxgGQGRQAQyY1IJVezQSDnlWhuqsvqRVbQrtv2EE";
      };
      version = "6.6.7";
      modDirVersion = "6.6.7";
      };
  });

  # Add kernel parameters to better support suspend (i.e., "sleep" feature)
  boot.kernelParams = [ "mem_sleep_default=s2idle" "acpi_osi=\"!Windows 2020\""];

  # Configure how the system sleeps when the lid is closed;
  # this seems to not influence suspend behavior when the
  # laptop is connected to a dock-based power source
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "suspend";

  # Define the hostname
  networking.hostName = "diameno";

  # Enable networking
  networking.networkmanager.enable = true;

  # Although the iwd backend is suggested for
  # stability, it does not enable the wireless
  # network to resume after a sleep
  # networking.wireless.iwd.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";

  # Set your time zone
  time.timeZone = "America/New_York";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Define locale settings
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Setup hardware support to X11
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  # Do not use wayland
  services.xserver.displayManager.gdm.wayland = false;

  # Disable the GNOME Desktop Environment
  services.xserver.desktopManager.gnome.enable = false;

  # Disable the GNOME Desktop Manager that is for login
  services.xserver.displayManager.gdm.enable = false;

  # Enable i3
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.windowManager.i3.enable = true;

  # Configure the display manager
  services.xserver.displayManager.lightdm.greeters.mini = {
            enable = true;
            user = "gkapfham";
            extraConfig = ''
                [greeter]
                show-password-label = true
                password-alignment = left
                password-label-text = 
                [greeter-theme]
                font-size = 1.1em
                window-color = "#d78700"
                background-image = "/etc/lightdm/wallpaper.jpg"
                background-color = "#1c1c1c"
                border-color = "#080800"
                border-width = 2px
                layout-space = 15
                password-color = "#767676"
                password-background-color = "#1B1D1E"
                password-border-color = "#080800"
                password-border-width = 2px
            '';
        };

  # Use light from controlling backlight
  programs.light.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Fonts
  fonts.packages = with pkgs; [
    hack-font
    roboto-mono
    (nerdfonts.override { fonts = [ "Hack" "RobotoMono" ]; })
  ];

  # Enable support for Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  #services.blueman.enable = true;
  
  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # programs.zsh.enable = true;

  # Define a user account; password already created with passwd
  users.users.gkapfham = {
    isNormalUser = true;
    description = "Gregory M. Kapfhammer";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
      # terminal
      alacritty
      gnome.gnome-terminal
      kitty
      # cli
      bat
      cloc
      croc
      eva
      eza
      fzf
      lesspipe
      neofetch
      ripgrep
      ripgrep-all
      rtx
      tmuxinator
      # browsers
      brave
      chromium
      firefox
      discord
      # desktop
      clipmenu
      dmenu
      dunst
      feh
      i3wsr
      maim
      polybar
      rofi
      rofimoji
      xbanish
      xbindkeys
      # development
      ruff
      # editors
      neovim
      universal-ctags
      vim
      # mail
      gettext
      isync
      msmtp
      mutt
      mutt-wizard
      neomutt
      pass
      # theme
      fluent-gtk-theme
      nordic
      layan-gtk-theme
      numix-gtk-theme
      numix-sx-gtk-theme
      omni-gtk-theme
      # utilities
      atuin
      fasd
      fd
      gh
      jq
      mupdf
      pandoc
      powertop
      starship
      stow
      stress-ng
      unzip
      urlview
      vlc
      zoxide
      zathura
    ];
  };

  # Use the neovim editor for the defaults
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate = _: true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs;
   [
    bibtool
    curl
    easyeffects
    gcc
    gnumake
    linuxKernel.packages.linux_zen.cpupower
    libsecret
    lm_sensors
    lxappearance
    killall
    i3
    i3lock-fancy-rapid
    iw
    iwd
    file
    fwupd
    gimp
    git
    git-extras
    gnupg
    gnome.adwaita-icon-theme
    gnome.seahorse
    hsetroot
    htop
    iotop
    killall
    libnotify
    lightdm-mini-greeter
    numlockx
    pavucontrol
    phinger-cursors
    picom-allusive
    pinentry-gtk2
    pinentry-gnome
    rng-tools
    sct
    sshfs
    texlive.combined.scheme-full
    themechanger
    tmux
    tree
    wget
    xclip
    xcape
    xdotool
    xorg.xbacklight
    xorg.xcursorthemes
    xorg.xinit
    xorg.xrdb
    zlib
    zip
    xsel
    zsh
    zsh-autocomplete
    # programming
    lua5_3_compat
    nodejs_21
    marksman
    pipx
    python3
    python311Packages.pip
    lua-language-server
    nodePackages.pyright
    ruff-lsp
    vscode-langservers-extracted
    yaml-language-server
];

  # Enable update of the firmware through Linux
  services.fwupd.enable = true;

  # Enable the bolt protocol for thunderbolt docks
  services.hardware.bolt.enable = true;

  # Use zsh as the default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.pathsToLink = [ "/libexec" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  # List services that you want to enable:

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;

  # Ssh agent
  programs.ssh.startAgent = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
