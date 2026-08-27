# Merge the exact library set that nixpkgs' own `electron` package uses into
# one store path, so the terminal-browser bundled Electron can find the
# glibc-style shared libraries that NixOS does not provide in /usr/lib.
#
# The lib set (electron-rpath.txt) was extracted from the unwrapped electron
# binary's embedded RPATH:
#   nix-shell -p electron patchelf --run \
#     'patchelf --print-rpath $(readlink -f $(which electron))'
#
# NOTE: this uses stdenv.mkDerivation (not runCommand) on purpose — runCommand
# externalizes buildCommand via passAsFile, which hides the /nix/store/*
# references from the sandbox input scanner. mkDerivation keeps buildCommand
# as a scanned env var, so the 39 library dirs are declared as real inputs and
# are present inside the build sandbox.
{ pkgs ? import <nixpkgs> { } }:
let
  rpathFile = ./electron-rpath.txt;
  raw = pkgs.lib.splitString ":" (builtins.readFile rpathFile);
  # Wrap each dir in builtins.storePath so string interpolation carries real
  # store-path context: this makes every dir a declared input of the
  # derivation, so the build sandbox actually mounts them.
  dirs = map builtins.storePath (builtins.filter
    (d: d != "$ORIGIN" && d != "")
    (map (pkgs.lib.removeSuffix "\n") raw));
  quote = d: "\"${d}\"";
in
pkgs.stdenv.mkDerivation {
  pname = "terminal-browser-electron-libs";
  version = "1";
  buildCommand = ''
    mkdir -p $out/lib $out/lib64
    for d in ${builtins.concatStringsSep " " (map quote dirs)}; do
      case "$d" in
        */lib64) tgt="$out/lib64" ;;
        *)       tgt="$out/lib" ;;
      esac
      ln -sfn "$d"/* "$tgt"/
    done
  '';
}