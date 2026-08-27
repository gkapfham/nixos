#!/usr/bin/env bash
# =============================================================================
# terminal-browser on NixOS — bootstrap installer
#
# Makes the upstream-installed terminal-browser bundle (its Electron binary)
# run on NixOS, where the glibc-style system libraries (/usr/lib, /lib64)
# that Electron needs are not provided by the distribution.
#
# Usage:
#   ./install-terminal-browser.sh             full bootstrap (idempotent)
#   ./install-terminal-browser.sh --reapply   re-apply shim after an upgrade
#
# Environment:
#   TERMINAL_BROWSER_APP_DIR   override app location (default ~/.local/share/terminal-browser)
#
# See README.md in this directory for the full explanation.
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${TERMINAL_BROWSER_APP_DIR:-$HOME/.local/share/terminal-browser}"
BIN_DIR="${TERMINAL_BROWSER_BIN_DIR:-$HOME/.local/bin}"
RPATH_FILE="$REPO_DIR/electron-rpath.txt"
LIBS_NIX="$REPO_DIR/electron-libs.nix"
GCROOT_DIR="${GCROOT_DIR:-$HOME/.gcroots}"
GCROOT_LINK="$GCROOT_DIR/terminal-browser-libs"
ELECTRON_DIR="$APP_DIR/app/electron"
MODE="${1:-bootstrap}"

say() { printf '\033[1;32m[tb]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[tb]\033[0m ERROR: %s\n' "$*" >&2; exit 1; }

require_prereqs() {
  for bin in nix-build nix-store curl; do
    command -v "$bin" >/dev/null 2>&1 || die "missing prerequisite: $bin"
  done
}

install_cli() {
  say "installing terminal-browser via the upstream script..."
  say "(its 'apt-get install' step is expected to fail on NixOS and is harmless)"
  if ! curl -fsSL https://terminal-browser.sh/install | bash; then
    # upstream script may exit non-zero where no apt/dnf installer applies;
    # the CLI is still installed in that case, so verify instead of dying.
    :
  fi
  [ -x "$BIN_DIR/terminal-browser" ] || die "terminal-browser CLI not found: $BIN_DIR/terminal-browser"
  say "CLI installed at $BIN_DIR/terminal-browser"
}

# Every non-$ORIGIN entry in the rpath file must exist in the store; they are
# pinned to the nixpkgs revision they were extracted from (and kept alive by
# the GC root, so they will not disappear on this machine).
rpath_is_valid() {
  [ -f "$RPATH_FILE" ] || return 1
  local d
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    [ "$d" = '$ORIGIN' ] && continue
    [ -d "$d" ] || return 1
  done < <(tr ':' '\n' < "$RPATH_FILE")
}

regenerate_rpath() {
  say "regenerating electron-rpath.txt from nixpkgs' electron-unwrapped RPATH..."
  local wrapper unwrapped
  wrapper="$(nix-shell -p electron patchelf --run 'readlink -f "$(command -v electron)"')"
  unwrapped="$(grep -oE '/nix/store/[a-z0-9]{32}-electron-unwrapped[^" ]*/libexec/electron/electron' "$wrapper" | head -1)"
  [ -n "$unwrapped" ] || die "could not locate electron-unwrapped binary in $wrapper"
  nix-shell -p electron patchelf --run "patchelf --print-rpath '$unwrapped'" \
    | tr ':' '\n' | grep -v '^\$ORIGIN$' | grep -v '^$' | paste -sd: - > "$RPATH_FILE.tmp"
  mv "$RPATH_FILE.tmp" "$RPATH_FILE"
  say "wrote $RPATH_FILE"
}

build_libs() {
  say "building merged system-libs store path ($LIBS_NIX)..."
  nix-build "$LIBS_NIX" | tail -1
}

register_gcroot() {
  local out="$1"
  mkdir -p "$GCROOT_DIR"
  nix-store --add-root "$GCROOT_LINK" -r "$out" >/dev/null
  say "GC root: $GCROOT_LINK -> $out"
}

write_shim() {
  local libs="$1"
  cat > "$ELECTRON_DIR/electron" <<SHIM
#!/bin/sh
# NixOS shim: give the bundled Electron the glibc-style system libraries that
# NixOS lacks. Merged libs built from electron-libs.nix (keep the repo copy:
# ~/configure/nixos/terminal-browser). The GC root keeps this store path alive.
LIBS=$libs
export LD_LIBRARY_PATH="\$LIBS/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "\$(dirname "\$0")/electron.real" "\$@"
SHIM
  chmod +x "$ELECTRON_DIR/electron"
}

apply_shim() {
  local libs="$1"
  [ -d "$ELECTRON_DIR" ] || die "electron dir not found: $ELECTRON_DIR (run without --reapply to install first)"
  if [ -f "$ELECTRON_DIR/electron" ] && grep -q "NixOS shim" "$ELECTRON_DIR/electron" 2>/dev/null \
     && [ -x "$ELECTRON_DIR/electron.real" ]; then
    say "shim already in place"
    return 0
  fi
  # The current electron is a real (upstream) binary. Drop any stale
  # electron.real left from a previous shim session, then move it aside.
  rm -f "$ELECTRON_DIR/electron.real"
  mv "$ELECTRON_DIR/electron" "$ELECTRON_DIR/electron.real"
  write_shim "$libs"
  say "shim installed at $ELECTRON_DIR/electron"
}

verify() {
  if [ -x "$BIN_DIR/terminal-browser" ]; then
    local v
    if v="$("$BIN_DIR/terminal-browser" --version 2>&1)"; then
      say "terminal-browser: $v"
    else
      printf '\033[1;33m[tb]\033[0m WARNING: CLI check failed:\n%s' "$v" >&2
      printf '\033[1;33m[tb]\033[0m (libs + shim are in place; see the sandbox notes in README.md)\n' >&2
    fi
  else
    say "note: terminal-browser CLI not installed here (run without --reapply to install it)"
  fi
}

main() {
  require_prereqs

  if [ "$MODE" = "bootstrap" ] && [ ! -x "$BIN_DIR/terminal-browser" ]; then
    install_cli
  fi

  if rpath_is_valid; then
    say "using saved lib set: $RPATH_FILE"
  elif [ "$MODE" = "bootstrap" ]; then
    regenerate_rpath
  else
    die "saved lib set is stale (store paths missing) and --reapply cannot rebuild it; run without --reapply"
  fi

  libs="$(build_libs)"
  register_gcroot "$libs"
  apply_shim "$libs"
  verify
}

main