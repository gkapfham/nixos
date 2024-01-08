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
  boot.kernelParams = [ "mem_sleep_default=s2idle" "acpi_osi=\"!Windows 2020\"" ];

  # Configure how the system sleeps when the lid is closed;
  # specifically, it should sleep or suspend in all cases
  # --> when running on battery power
  # --> when connected to external power
  # --> when connected to a dock that has external power
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "suspend";
  services.logind.lidSwitchDocked = "suspend";

  # Define the hostname
  networking.hostName = "diameno";

  # Enable networking
  networking.networkmanager.enable = true;

  # Automatically set the regulatory domain for
  # the wireless network card
  hardware.wirelessRegulatoryDatabase = true;

  # Disable light sensors and accelerometers as
  # they are not used and consume extra battery
  hardware.sensor.iio.enable = false;

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

  # Enhanced power management with power-profiles-daemon
  # Reference: https://github.com/tlvince/nixos-config
  nixpkgs.overlays = [
    (
      final: prev: {
        power-profiles-daemon = prev.power-profiles-daemon.overrideAttrs (
          old: {
            version = "0.13-1";

            patches =
              (old.patches or [])
              ++ [
                (prev.fetchpatch {
                  url = "https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/merge_requests/127.patch";
                  sha256 = "sha256-k5c2Gy2r/my3Uc9rBVdnQqr5Fe/QBPcvLLuF8mI8zmA=";
                })
              ];
            # Explicitly fetching the source to make sure we're patching over 0.13 (this isn't strictly needed):
            src = prev.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "upower";
              repo = "power-profiles-daemon";
              rev = "0.13";
              sha256 = "sha256-ErHy+shxZQ/aCryGhovmJ6KmAMt9OZeQGDbHIkC0vUE=";
            };
          }
        );
      }
    )
  ];

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

  # Configure the display manager;
  # note that this assumes that the wallpaper.jpg
  # file was manually moved to this location.
  # Overall, it seems as though there is no other way
  # to reference a wallpaper in a user account or to
  # preload the wallpaper to the /etc/lightdm directory
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
                background-image = ""
                background-color = "#875f87"
                border-color = "#080800"
                border-width = 2px
                layout-space = 15
                password-color = "#a8a8a8"
                password-background-color = "#1B1D1E"
                password-border-color = "#d78700"
                password-border-width = 2px
            '';
        };

  # Use light from controlling backlight; see
  # the i3 configuration for more details on
  # how to use command with the i3 window manager
  programs.light.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Install fonts; note that this ensures the Nerd fonts
  # with all of their affiliated symbols are applied
  # to the fonts that are installed from Nix packages
  fonts.packages = with pkgs; [
    hack-font
    roboto-mono
    (nerdfonts.override { fonts = [ "Hack" "RobotoMono" ]; })
  ];

  # Enable support for Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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
  services.xserver.libinput.enable = true;

  # Define a user account; password already created with passwd
  # User Packages: add the user's packages in separate sections
  # with each section organized in increasing alphabetical order
  users.users.gkapfham = {
    isNormalUser = true;
    description = "Gregory M. Kapfhammer";
    extraGroups = [ "networkmanager" "wheel" "video" "input" ];
    packages = with pkgs; [
      # terminal
      alacritty
      gnome.gnome-terminal
      kitty
      # cli
      abook
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
      yazi
      # browsers
      brave
      chromium
      discord
      firefox
      w3m
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
      # utilities
      atuin
      fasd
      fd
      gh
      jq
      mupdf
      pandoc
      powerstat
      powertop
      starship
      stow
      stress-ng
      unzip
      urlview
      vlc
      zathura
      zoxide
    ];
  };

  # Use the neovim editor for the defaults
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate = _: true;

  # List packages installed in system profile
  # System Packages: install programs that are
  # available to all uses on the laptop
  environment.systemPackages = with pkgs;
   [
    # tools and libraries
    acpi
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    bibtool
    curl
    du-dust
    easyeffects
    gcc
    gnumake
    killall
    libinput-gestures
    linuxKernel.packages.linux_zen.cpupower
    lm_sensors
    lxappearance
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
    pinentry-gnome
    poppler
    pulseaudioFull
    rng-tools
    sct
    sshfs
    texlab
    texlive.combined.scheme-full
    themechanger
    tmux
    tree
    unar
    wget
    wmctrl
    wordnet
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
    pipx
    prettierd
    python3
    python311Packages.pip
    python311Packages.pydocstyle
    quarto
    # language servers
    lua-language-server
    marksman
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

  # Expose binaries in the Nix store
  environment.pathsToLink = [ "/libexec" ];

  # Define the GNU gpg agent for the use
  # of programs like pass; make sure that
  # there is a pineentryFlavor defined so
  # that it is possible to enter passwords
  # when running programs like neomutt
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  # Enable the ssh agent
  programs.ssh.startAgent = true;

  # Enable the Gnome keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;

  # Configure automatic garbage collection for NixOS state
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    randomizedDelaySec = "1 hour";
  };

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
