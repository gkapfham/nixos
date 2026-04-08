# NixOS Configuration Guide

This document provides essential context for working with this NixOS system configuration.

## System Overview

- **Hostname**: `diameno`
- **Platform**: Framework 13 AMD (7040 series)
- **Architecture**: x86_64-linux
- **NixOS Version**: 23.11 (stateVersion)
- **Kernel**: linux_6_18 (pinned, not latest)
- **Window Manager**: i3 (X11, not Wayland)
- **Display Manager**: LightDM with GTK greeter

## Configuration Structure

```
/etc/nixos/
├── configuration.nix          # Main system configuration
├── hardware-configuration.nix # Hardware-specific settings (auto-generated)
├── unstable.nix               # Unstable channel packages overlay
└── media/
    └── wallpaper.png          # LightDM background
```

### Key Configuration Files

#### 1. `configuration.nix`

- **Purpose**: Main system configuration
- **User**: `gkapfham` (normal user, wheel group)
- **Shell**: zsh (default)
- **Key imports**:
  - `<nixos-hardware/framework/13-inch/7040-amd>` - Framework-specific tweaks
  - `./hardware-configuration.nix` - Hardware scan results
  - `./unstable.nix` - Unstable package overlay

#### 2. `unstable.nix`

- **Purpose**: Overlay for packages from the unstable channel
- **Key packages**: neovim, quarto, python314, fzf, zellij, opencode, and many dev tools
- **Note**: Requires `nixos-unstable` channel to be added:
  ```bash
  sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
  sudo nix-channel --update
  ```

#### 3. `hardware-configuration.nix`

- **Purpose**: Auto-generated hardware configuration
- **DO NOT EDIT** manually - regenerate with `nixos-generate-config` if hardware changes

## Flakes Status

**⚠️ IMPORTANT**: This system does NOT use flakes.

- No `flake.nix` exists
- No `flake.lock` exists
- Traditional channel-based workflow is used
- User explicitly wants to avoid flakes

## Package Management

### Adding System Packages

Add to `environment.systemPackages` in `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  # existing packages...
  new-package-name
];
```

### Adding User Packages

Add to `users.users.gkapfham.packages` in `configuration.nix`:

```nix
users.users.gkapfham = {
  # ...existing config...
  packages = with pkgs; [
    # existing packages...
    new-user-package
  ];
};
```

### Using Unstable Packages

For packages that need to be from unstable:

1. Add to `unstable.nix` in the `environment.systemPackages` list:

   ```nix
   unstable.package-name
   ```

1. Or reference in `configuration.nix` via the `unstable` attribute:

   ```nix
   environment.systemPackages = with pkgs; [
     unstable.some-package
   ];
   ```

### Custom Derivations

For packages not in nixpkgs, create a derivation in `configuration.nix`:

```nix
let
  my-package = pkgs.stdenv.mkDerivation rec {
    pname = "my-package";
    version = "1.0.0";
    src = pkgs.fetchurl {
      url = "https://example.com/releases/${version}.tar.gz";
      sha256 = "..."; # Use lib.fakeSha256 first, then replace with actual
    };
    # ... build instructions ...
  };
in
{
  environment.systemPackages = with pkgs; [
    my-package
  ];
}
```

## Applying Changes

### Standard Rebuild

```bash
sudo nixos-rebuild switch
```

### Test Configuration (without applying)

```bash
sudo nixos-rebuild test
```

### Build but don't switch (dry run)

```bash
sudo nixos-rebuild build
```

### Update channels and rebuild

```bash
sudo nix-channel --update
sudo nixos-rebuild switch
```

## Safety Guidelines

### DO:

- ✅ Make minimal, focused changes
- ✅ Test with `nixos-rebuild test` when possible
- ✅ Keep backups of working configurations
- ✅ Use `git` to track changes to `/etc/nixos`
- ✅ Ask user before modifying system-critical settings
- ✅ Prefer user-space installation over system-wide when uncertain

### DON'T:

- ❌ Enable flakes or modify `nix.conf` to use flakes
- ❌ Change `system.stateVersion`
- ❌ Modify `hardware-configuration.nix` directly
- ❌ Run `nix-collect-garbage -d` without user consent
- ❌ Change bootloader settings without explicit permission
- ❌ Modify kernel settings unless specifically requested

## System-Specific Notes

### Fingerprint Reader

- Enabled via `services.fprintd.enable = true`
- PAM configuration customized for LightDM fingerprint auth
- Does NOT use fingerprint for `login` service (only gdm-fingerprint)

### Power Management

- Uses `auto-cpufreq` instead of `tlp`
- `power-profiles-daemon` is disabled
- Kernel params include suspend optimizations for Framework 13

### Development Environment

- Python: 3.14 (unstable) with many packages
- Node.js: 22 (from nixpkgs)
- Go, Zig, Rust (via rustup), Java (OpenJDK), R
- Neovim: Unstable version with Python/Lua support

### Network

- Netbird VPN enabled (`services.netbird.enable = true`)
- SSH server enabled (`services.openssh.enable = true`)
- Firewall disabled (`networking.firewall.enable = false`)

## User Preferences

Based on configuration analysis:

- Prefers stability and reversibility
- Wants to avoid flakes
- Uses i3 window manager extensively
- Heavy terminal/cli user
- Values battery life (Framework laptop optimizations)
- Prefers zsh shell with many CLI tools

## Troubleshooting

### "undefined variable" errors

- Check if package is in unstable - may need to use `unstable.package-name`
- Ensure `with pkgs;` is used in package lists

### Channel issues

```bash
# List channels
sudo nix-channel --list

# Update channels
sudo nix-channel --update

# Verify channel is working
nix-channel --list
```

### Rollback if system breaks

```bash
# Boot from previous generation in bootloader
# Or rollback to current generation:
sudo nixos-rebuild switch --rollback
```
