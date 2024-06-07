# NixOS configuration for unstable packages;
# this is only used since there are certain
# programs, most notably neovim, that are not
# available at their latest version in the
# stable channel, thus prompting the limited
# use of the unstable channel

{ config, pkgs, ... }:

let
  baseconfig = { allowUnfree = true; };
  unstable = import <nixos-unstable> { config =  baseconfig; };
in
{
  environment.systemPackages = with pkgs; [
    # Neovim; note that the most recent version is
    # only available through the unstable channel
    (import (fetchTarball "channel:nixos-unstable") {}).neovim
    (import (fetchTarball "channel:nixos-unstable") {}).tree-sitter
    (import (fetchTarball "channel:nixos-unstable") {}).vim
  ];
}
