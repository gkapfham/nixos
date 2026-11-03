#!/usr/bin/env bash
# =============================================================================
# terminal-browser on NixOS — remove the LD_LIBRARY_PATH shim
#
# Superseded by configuration.nix -> programs.nix-ld.libraries, which hands the
# same desktop libraries to unpatched binaries, so the shim is no longer needed.
# This restores the upstream Electron binary and refuses to do so while the
# binary still cannot resolve its libraries on its own.
#
# Usage: ./de-shim.sh
#
# Environment:
#   TERMINAL_BROWSER_APP_DIR   override app location (default ~/.local/share/terminal-browser)
# =============================================================================

set -euo pipefail

APP_DIR="${TERMINAL_BROWSER_APP_DIR:-$HOME/.local/share/terminal-browser}"
ELECTRON_DIR="$APP_DIR/app/electron"

say() { printf '\033[1;32m[tb]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[tb]\033[0m ERROR: %s\n' "$*" >&2; exit 1; }

# The shim moved the upstream binary aside as <name>.real; upstream calls it
# pixel since v0.11.1 and electron before that.
name=""
for n in pixel electron; do
  [ -x "$ELECTRON_DIR/$n.real" ] && name="$n"
done
if [ -z "$name" ]; then
  say "no shim found in $ELECTRON_DIR (nothing to do)"
  exit 0
fi

# Guard: the real binary must load its libraries through nix-ld alone. Clear
# LD_LIBRARY_PATH so the shim's own setting cannot mask a missing nix-ld entry,
# and run in node mode so no display is needed.
if ! ELECTRON_RUN_AS_NODE=1 env -u LD_LIBRARY_PATH "$ELECTRON_DIR/$name.real" --version >/dev/null 2>&1; then
  die "$name.real cannot load its libraries yet; rebuild first ('kix'), then retry"
fi

rm -f "$ELECTRON_DIR/$name"
mv "$ELECTRON_DIR/$name.real" "$ELECTRON_DIR/$name"
say "shim removed: $ELECTRON_DIR/$name is the upstream binary again"
