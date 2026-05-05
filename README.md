# 📘 Framework 13 AMD Laptop NixOS Configuration

This repository contains a reproducible NixOS setup for the Framework 13 AMD
laptop. It includes hardware support, system configuration, and customizations
for optimal performance and usability. Use this as a starting point or reference
for your own NixOS installation on this device.

Think about the following issues before adopting this NixOS configuration:

- **Hardware Compatibility**: Ensure your Framework 13 AMD laptop has the same
  or compatible hardware components as those specified in the configuration.
- **Security Considerations**: Review the security settings and ensure they
  meet your requirements. Consider additional security measures if needed.
- **Customization**: This configuration is tailored to my specific needs and
  preferences. You may need to modify it to suit your workflow and preferences.
- **Maintenance**: Regularly update the configuration and packages to ensure
  security and compatibility.
- **Backup**: Before making significant changes to your system (e.g.,
  installing NixOS for the first time), ensure that you have backups of your data
  and configuration files.

## 📑 Table of Contents

- [📦 Imports](#-imports)
- [🔧 Bootloader](#-bootloader)
- [🐧 Linux Kernel](#-linux-kernel)
- [💤 Sleep Configuration](#-sleep-configuration)
- [🌐 Networking](#-networking)
- [🌍 Localization](#-localization)
- [🖥️ X11 Windowing System](#%EF%B8%8F-x11-windowing-system)
- [🖱️ Input Devices](#-input-devices)
- [🔊 Sound](#-sound)
- [🔋 Power Management](#-power-management)
- [📱 Bluetooth](#-bluetooth)
- [🖨️ Printing](#-printing)
- [🔤 Fonts](#-fonts)
- [👤 User Configuration](#-user-configuration)
- [📦 System Packages](#-system-packages)
- [🔒 Security](#-security)
- [🗑️ Garbage Collection](#-garbage-collection)
- [📅 System State Version](#-system-state-version)
- [🖥️ Hardware Configuration](#-hardware-configuration)
- [🚀 Unstable Packages](#-unstable-packages)

## 📦 Imports

- Customized configuration for Framework 13 AMD laptop
- Hardware scan results
- Unstable packages from the unstable channel

## 🔧 Bootloader

- Uses `systemd-boot`
- EFI variables enabled

## 🐧 Linux Kernel

- Pinned to Linux kernel version 6.16
- Sleep support with kernel parameters: `mem_sleep_default=s2idle`, `amdgpu.dcdebugmask=0x10`, `pcie_aspm=off`

## 💤 Sleep Configuration

- Kernel parameters for better suspend support
- Configured to suspend on lid close in all power states

## 🌐 Networking

- Hostname: `diameno`
- NetworkManager enabled
- Wireless regulatory database enabled
- Firewall disabled for local services
- Tailscale enabled for secure networking

## 🌍 Localization

- Time zone: America/New_York
- Locale: en_US.UTF-8
- Extra locale settings for various LC categories

## 🖥️ X11 Windowing System

- X11 enabled
- OpenGL support enabled
- Wayland disabled
- LightDM with mini greeter (custom themed)
- i3 window manager enabled
- GNOME desktop environment disabled

## 🖱️ Input Devices

- Touchpad support enabled
- Custom keymap configuration

## 🔊 Sound

- Pipewire enabled for sound
- PulseAudio disabled
- RTKit enabled

## 🔋 Power Management

- Light utility for backlight control
- auto-cpufreq enabled with battery/charger profiles
- TLP and power-profiles-daemon disabled in favor of auto-cpufreq
- Automatic USB device mounting via devmon, gvfs, and udisks2

## 📱 Bluetooth

- Bluetooth hardware support enabled
- Automatic power-on at boot
- Blueman GUI manager enabled

## 🖨️ Printing

- CUPS printing service enabled

## 🔤 Fonts

- Maple Mono Nerd Fonts (Normal and NF variants)
- Hack Nerd Font
- JetBrains Mono Nerd Font
- Monaspace Nerd Font
- Roboto Mono Nerd Font

## 👤 User Configuration

- User: `gkapfham`
- Groups: networkmanager, wheel, video, input
- **Terminal Emulators**: alacritty, gnome-terminal, kitty
- **CLI Tools**: abook, atuin, bat, bluetuith, bmon, borgbackup, borgmatic, bore-cli, cloc, croc, dig, eva, eza, fasd, fastfetch, fd, flyctl, gh, gron, gum, ijq, imagemagick, jless, jq, lesspipe, miniserve, mupdf, neofetch, netscanner, pandoc, pastel, pkg-config, powerstat, powertop, qrencode, ripgrep, ripgrep-all, rm-improved, starship, stow, stress-ng, systemctl-tui, tealdeer, tmuxinator, tokei, trippy, unzip, urlscan, vlc, yazi, yq-go, zathura
- **Browsers**: brave, chromium, discord, firefox, floorp, lynx, qutebrowser, w3m, weylus
- **Desktop Utilities**: clipmenu, dmenu, dunst, feh, i3wsr, j4-dmenu-desktop, maim, polybar, rofi, rofimoji, xbanish, xbindkeys
- **Development**: mise (dev environment manager)
- **Mail Clients**: aerc, gettext, himalaya, inetutils, isync, msmtp, mutt, mutt-wizard, neomutt, pass
- **Themes**: adwaita-qt, fluent-gtk-theme
- **Databases**: duckdb
- **AI/LLMs**: ollama

## 📦 System Packages

- **Development Tools**: android-tools, clippy, gcc, gcc-unwrapped, git, git-extras, gnumake, go, lua5_3_compat, luajitPackages.tiktoken_core, nodejs_22, openjdk, maven, mise, pipx, prettierd, R, texlab, texlive.combined.scheme-full, universal-ctags, zulu
- **Language Servers**: copilot-language-server, gopls, lua-language-server, marksman, nil, pyright, rust-analyzer, statix, vscode-langservers-extracted, yaml-language-server
- **System Utilities**: acpi, arandr, aspell (with dictionaries), bibtool, bottom, csvlens, curl, dua, du-dust, evince, fwupd, fw-ectool, gdu, ghostscript, highlight-pointer, htop, iotop, killall, libgit2, libnotify, lm_sensors, manix, microcode-amd, networkmanagerapplet, nix-search-cli, nix-tree, nmap, numlockx, nvme-cli, pavucontrol, pciutils, pngquant, poppler, poppler_utils, procs, pstree, pulseaudioFull, rclone, rng-tools, sct, sesh, sqlite, sshfs, tmux, tree, unar, upower, wavemon, wget, wirelesstools, wmctrl, wordnet, xclip, xcape, xdotool, zenith, zk, zsh, zsh-autocomplete
- **Window Manager & Desktop**: adwaita-icon-theme, feh, gimp, hsetroot, i3, i3lock-fancy-rapid, iw, iwd, lightdm-mini-greeter, litemdview, lxappearance, phinger-cursors, pinentry-all, seahorse, themechanger, xorg packages (xbacklight, xcursorthemes, xev, xinit, xrdb, xwininfo)
- **File Management**: file, glow, mdcat, mdl, unar, xsel, zip, zlib

## 🔒 Security

- GPG agent enabled with pinentry-gnome3
- SSH agent enabled
- Gnome keyring enabled
- Fingerprint reader (fprintd) enabled
- i3lock with fingerprint authentication support

## 🗑️ Garbage Collection

- Automatic garbage collection enabled
- Weekly cleanup of old generations

## 🖥️ Hardware Configuration

- Imports hardware scan results
- Kernel modules for NVMe, USB, Thunderbolt, and storage
- AMD KVM module enabled
- Root filesystem on ext4
- Boot filesystem on vfat
- LUKS encryption for root filesystem
- DHCP enabled for networking
- AMD microcode updates enabled

## 🚀 Unstable Packages

- **Python 3.12**: Custom installation with packages including:
  - `bibtexparser`, `cairosvg`, `cryptography`, `csscompressor`, `distro`
  - `htmlmin`, `ipython`, `ipykernel`, `jupyter-client`, `jupyterlab`, `jupyterlab-git`
  - `pillow`, `pip`, `pipx`, `plotly`, `pnglatex`, `poetry-core`
  - `prompt-toolkit`, `pydocstyle`, `pynvim`, `pyperclip`, `python-dotenv`
  - `pyudev`, `pyyaml`, `requests`, `rich`, `rjsmin`, `systemd`
- **Quarto**: Stable version with custom Python packages integration
- **Neovim**: Unstable version with Lua (magick) and Python packages for plugins
- **Development Tools**: ast-grep, cargo, copilot-language-server, deskflow, decktape, harper, rustc, rustfmt, uv, ty
- **Utilities**: fzf, fzy, i3status, jupyter, opencode, poetry, poppler, pyrefly, tree-sitter, ruff, picom, zoxide
