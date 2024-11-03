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
  baseconfig = { allowUnfree = true; };
  unstable = import <nixos-unstable> { config =  baseconfig; };
  stable = import <nixos> { config =  baseconfig; };

  # define the Python packages that should always be available
  # inside of both system-wide Python and Quarto
  default-python-packages = python-packages: with python-packages; [
    bibtexparser
    cairosvg
    cryptography
    csscompressor
    htmlmin
    ipython
    ipykernel
    jupyter-client
    jupyterlab
    jupyterlab-git
    pillow
    pip
    pipx
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

  # use the unstable version of Python
  # with all of the custom packages defined
  # by the default-python-packages variable
  python-with-custom-packages = unstable.python312.withPackages default-python-packages;

  # use the unstable version of Quarto
  # with all of the custom packages defined
  # by the default-python-packages variable
  quarto-with-custom-python-packages = stable.quarto.override {
  # quarto-with-custom-python-packages = unstable.quarto.override {
    python3 = python-with-custom-packages;
    extraPythonPackages = default-python-packages;
  };

  # use the unstable version of Neovim
  # with a restricted number of Lua and Python
  # packages for chosen plugins (note that the
  # neovim configuration is defined in my dotfiles
  # repository using Lazy.nvim and not in NixOS)
  neovim-with-custom-python-packages = unstable.neovim.override {
    extraLuaPackages = p: with p; [
      magick
     ];
    extraPython3Packages = p: with p; [
      cairosvg
      cryptography
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

  # define the unstable (and specially configured) 
  # system packages that are available to all users
  # environment.systemPackages = with pkgs; [
  environment.systemPackages = [
    python-with-custom-packages
    quarto-with-custom-python-packages
    neovim-with-custom-python-packages
    # (import (fetchTarball "channel:nixos-unstable") {}).neovim
    # unstable.neovim
    unstable.jupyter
    unstable.poetry
    unstable.tree-sitter
    unstable.ruff
    unstable.ruff-lsp
    unstable.picom
  ];

  # Use the neovim editor for the defaults
  # programs.neovim.enable = true;
  # programs.neovim.defaultEditor = true;

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = unstable;
  };
}
