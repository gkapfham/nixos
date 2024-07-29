# Nix configuration for the Framework 13 AMD laptop; parts of
# this were automatically generated by the NixOS installer while
# other content was written and/or customized by Gregory M. Kapfhammer.

{ pkgs, ... }:

{

  # Load other configuration files
  imports =
    [
      # Add customized configuration for Framework 13 AMD laptop
      <nixos-hardware/framework/13-inch/7040-amd>
      # Include the results of the hardware scan
      ./hardware-configuration.nix
      # Include the unstable packages from unstable channel
      ./unstable.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Add kernel parameters to better support suspend (i.e., "sleep" feature)
  boot.kernelParams = [ "mem_sleep_default=s2idle" "acpi_osi=\"!Windows 2020\"" "amdgpu.sg_display=0"];

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
  # stability, it may not enable the wireless
  # network to resume after a sleep and the
  # network daemon may not always connect. 
  # networking.wireless.iwd.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";

  # Set your time zone
  time.timeZone = "America/New_York";

  # Select internationalization properties
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
  services.displayManager.defaultSession = "none+i3";
  services.xserver.windowManager.i3.enable = true;

  # Configure the display manager; note that this displays
  # a small box for an input password in the center of the
  # screen. The current implementation seems to ignore the
  # show-sys-info parameter, the likes of which are not visible
  services.xserver.displayManager.lightdm.greeters.mini = {
            enable = true;
            user = "gkapfham";
            extraConfig = ''
                [greeter]
                show-password-label = true
                password-alignment = left
                password-input-width = 20
                password-label-text =  Password
                invalid-password-text = 󰋮 Invalid Password
                show-sys-info = true
                [greeter-hotkeys]
                # "alt", "control" or "meta"
                # meta is the windows/super key
                mod-key = meta
                # power management shortcuts (single-key, case-sensitive)
                shutdown-key = p
                restart-key = r
                hibernate-key = h
                suspend-key = s
                # cycle through available sessions
                session-key = e
                [greeter-theme]
                text-color = "#1c1c1c"
                font-size = 1.1em
                window-color = "#875f87"
                background-image = ""
                background-color = "#875f87"
                border-color = "#875f87"
                border-width = 2px
                layout-space = 15
                password-color = "#a8a8a8"
                password-background-color = "#1B1D1E"
                password-border-color = "#875f87"
                password-border-width = 2px
                sys-info-font-size = 1.1em
                sys-info-color = "#1c1c1c"
            '';
        };

  # Use light for controlling the backlight; see
  # the i3 configuration for more details on
  # how to use command with the i3 window manager
  programs.light.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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
  services.blueman.enable = true;

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
  };

  # Enable touchpad support (enabled default in most desktopManager)
  services.libinput.enable = true;

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
      bluetuith
      bmon
      cloc
      croc
      dig
      eva
      eza
      fzf
      imagemagick
      lesspipe
      miniserve
      neofetch
      netscanner
      pastel
      ripgrep
      ripgrep-all
      rm-improved
      systemctl-tui
      tealdeer
      tmuxinator
      trippy
      yazi
      # browsers
      brave
      chromium
      discord
      firefox
      qutebrowser
      w3m
      # desktop
      clipmenu
      dmenu
      dunst
      feh
      i3wsr
      maim
      rofi
      rofimoji
      xbanish
      xbindkeys
      # development
      ast-grep
      mise
      ruff
      # editors
      universal-ctags
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
      bore-cli
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
      tokei
      unzip
      urlscan
      vlc
      zathura
      zoxide
      # llms
      ollama
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
    arandr
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    bibtool
    bottom
    curl
    dua
    du-dust
    easyeffects
    evince
    gcc
    gcc-unwrapped
    gnumake
    killall
    lazygit
    libinput-gestures
    linuxKernel.packages.linux_zen.cpupower
    lm_sensors
    lxappearance
    i3
    i3lock-fancy-rapid
    iw
    iwd
    file
    uv
    fwupd
    gimp
    gdu
    git
    git-extras
    glow
    gnupg
    gnome.adwaita-icon-theme
    gnome.seahorse
    hsetroot
    htop
    iotop
    killall
    libgit2
    libnotify
    lightdm-mini-greeter
    litemdview
    mdcat
    networkmanagerapplet
    nix-search-cli
    nix-tree
    numlockx
    pavucontrol
    phinger-cursors
    picom
    poppler
    pulseaudioFull
    procs
    pstree
    rclone
    rng-tools
    sct
    sshfs
    systemctl-tui
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
    zenith
    zsh
    zsh-autocomplete
    # programming
    cargo
    clippy
    (import (fetchTarball https://install.devenv.sh/latest)).default
    go
    lua5_3_compat
    nodejs_22
    pipx
    poetry
    prettierd
    R
    rustc
    rustfmt
    uv
    zulu
    # language servers
    gopls
    lua-language-server
    marksman
    nodePackages.pyright
    nil
    ruff-lsp
    rust-analyzer
    statix
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
    # pinentryFlavor = "gnome3";
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # Enable the ssh agent
  programs.ssh.startAgent = true;

  # Enable the Gnome keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;

  # Configure automatic garbage collection for NixOS state;
  # this controls the number of generations that are kept
  # inside of the Nix store and thus the number of system
  # configurations that are available for selection at boot
  nix.gc = {
    automatic = false;
    dates = "weekly";
    options = "--delete-older-than 30d";
    randomizedDelaySec = "1 hour";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g., run man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";

}
