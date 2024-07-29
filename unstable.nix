# NixOS configuration for unstable packages;
# this is only used since there are certain
# programs, most notably neovim, that are not
# available at their latest version in the
# stable channel, thus prompting the limited
# use of the unstable channel.

# Note that this also handles the configuration of
# - Python packages available in NixOS
# - Python
# - Quarto

# Note that this file assumes that the following command
# has already been run to add the unstable channel:
# nix-channel --add https://nixos.org/channels/nixos-unstable unstable
# (I ran this command without being root and this works; with that
# said it makes more sense that I should have run it as root).

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball {
    config = config.nixpkgs.config;
  };

  # define the Python packages that should always be available
  # inside of both system-wide Python and Quarto
  default-python-packages = python-packages: with python-packages; [
    bibtexparser
    cairosvg
    csscompressor
    htmlmin
    ipython
    ipykernel
    jupyter-client
    jupyterlab
    jupyterlab-git
    pillow
    pip
    plotly
    pnglatex
    poetry-core
    prompt-toolkit
    pydocstyle
    pynvim
    pyperclip
    python-dotenv
    pyyaml
    requests
    rich
    rjsmin
  ];

  python-with-custom-packages = unstable.python312.withPackages default-python-packages;

  quarto-with-custom-python-packages = unstable.quarto.override {
    python3 = python-with-custom-packages;
    extraPythonPackages = default-python-packages;
  };

  neovim-with-custom-python-packages = unstable.neovim.override {
    extraLuaPackages = p: with p; [
      magick
     ];
    extraPython3Packages = p: with p; [
      cairosvg
      ipython
      ipykernel
      jupyter-client
      nbformat
      plotly
      pnglatex
      pynvim
      pyperclip
      rich
    ];

  };

in
{

  environment.systemPackages = with pkgs; [
    python-with-custom-packages
    quarto-with-custom-python-packages
    neovim-with-custom-python-packages
    unstable.jupyter
    unstable.poetry
    unstable.tree-sitter
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = unstable;
  };
}

# { config, pkgs, ... }:
#
# let
#   baseconfig = { allowUnfree = true; };
#   unstable = import <nixos-unstable> { config =  baseconfig; };
# in
# {
#   environment.systemPackages = with pkgs; [
#     # Neovim; note that the most recent version is
#     # only available through the unstable channel
#     (import (fetchTarball "channel:nixos-unstable") {}).neovim
#     (import (fetchTarball "channel:nixos-unstable") {}).tree-sitter
#     (import (fetchTarball "channel:nixos-unstable") {}).vim
#   ];
# }
