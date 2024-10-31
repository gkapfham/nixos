# 📘 Framework 13 AMD Laptop NixOS Configuration

Welcome to the NixOS configuration repository for the Framework 13 AMD laptop!
This repository contains the configuration files and settings to set up and
customize your Framework 13 AMD laptop with NixOS.

## 📑 Table of Contents

- [📦 Imports](#-imports)
- [🔧 Bootloader](#-bootloader)
- [🐧 Linux Kernel](#-linux-kernel)
- [💤 Sleep Configuration](#-sleep-configuration)
- [🌐 Networking](#-networking)
- [🌍 Localization](#-localization)
- [🖥️ X11 Windowing System](#️-x11-windowing-system)
- [🖱️ Input Devices](#-input-devices)
- [🔊 Sound](#-sound)
- [🔋 Power Management](#-power-management)
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

- Uses systemd-boot
- EFI variables enabled

## 🐧 Linux Kernel

- Latest kernel from the NixOS channel
- Option to pin to a specific kernel version

## 💤 Sleep Configuration

- Kernel parameters for better suspend support
- Configured to suspend on lid close in all power states

## 🌐 Networking

- Hostname: `diameno`
- NetworkManager enabled
- Wireless regulatory database enabled

## 🌍 Localization

- Time zone: America/New_York
- Locale: en_US.UTF-8
- Extra locale settings for various LC categories

## 🖥️ X11 Windowing System

- X11 enabled
- OpenGL support enabled
- Wayland disabled
- LightDM with a custom mini greeter
- i3 window manager enabled

## 🖱️ Input Devices

- Touchpad support enabled
- Custom keymap configuration

## 🔊 Sound

- Pipewire enabled for sound
- PulseAudio disabled
- RTKit enabled

## 🔋 Power Management

- Light utility for backlight control
- Automatic garbage collection for NixOS state

## 👤 User Configuration

- User: `gkapfham`
- Groups: networkmanager, wheel, video, input
- Packages: terminal emulators, CLI tools, browsers, desktop utilities,
development tools, editors, mail clients, themes, utilities, and more

## 📦 System Packages

- Tools and libraries: acpi, arandr, aspell, bottom, curl, gcc, git, htop, i3,
lightdm-mini-greeter, manix, networkmanagerapplet, nix-search-cli, nmap,
pavucontrol, pulseaudioFull, tmux, wget, zsh, and more
- Programming languages and tools: cargo, go, lua, nodejs, pipx, poetry, R,
rustc, zulu
- Language servers: gopls, lua-language-server, marksman, pyright,
rust-analyzer, yaml-language-server

## 🔒 Security

- GPG agent enabled with pinentry-gnome3
- SSH agent enabled
- Gnome keyring enabled

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

- **Python Packages**: Uses the unstable version of Python 3.12 with custom
packages including:
  - `bibtexparser`
  - `cairosvg`
  - `cryptography`
  - `csscompressor`
  - `htmlmin`
  - `ipython`
  - `ipykernel`
  - `jupyter-client`
  - `jupyterlab`
  - `jupyterlab-git`
  - `pillow`
  - `pip`
  - `pipx`
  - `plotly`
  - `pnglatex`
  - `poetry-core`
  - `prompt-toolkit`
  - `pydocstyle`
  - `pynvim`
  - `pyperclip`
  - `python-dotenv`
  - `pyyaml`
  - `requests`
  - `rich`
  - `rjsmin`
- **Quarto**: Uses the stable version of Quarto with custom Python packages.
- **Neovim**: Uses the unstable version of Neovim with additional Lua and Python
packages for plugins.
- **Additional Unstable Packages**: Includes:
  - `jupyter`
  - `poetry`
  - `tree-sitter`
  - `ruff`
  - `ruff-lsp`
  - `picom`
