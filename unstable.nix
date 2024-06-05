# NixOS configuration for unstable packages

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
  ];
}
