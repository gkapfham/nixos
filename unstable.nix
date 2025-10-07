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

  # permit the installation of a program that has a known security
  # vulnerability in the current version; note that this is required
  # otherwise it is not possible to install the package
  baseconfig.permittedInsecurePackages = [
    "deskflow-1.19.0"
  ];

  # define the Python packages that should always be available
  # inside of both system-wide Python and Quarto
  default-python-packages = python-packages: with python-packages; [
    bibtexparser
    cairosvg
    cryptography
    csscompressor
    distro
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
    pyudev
    pyyaml
    requests
    rich
    rjsmin
    systemd
  ];

  # use the unstable version of Python
  # with all of the custom packages defined
  # by the default-python-packages variable
  python-with-custom-packages = unstable.python312.withPackages default-python-packages;

  # use the unstable version of Quarto
  # with all of the custom packages defined
  # by the default-python-packages variable
  quarto-with-custom-python-packages = unstable.quarto.override {
    python3 = python-with-custom-packages;
    extraPythonPackages = default-python-packages;
  };

  # use the unstable version of Neovim
  # with a restricted number of Lua and Python
  # packages for chosen plugins (note that the
  # neovim configuration is defined in my dotfiles
  # repository using Lazy.nvim and not in NixOS);
  # NOTE: temporarily stop using the unstable version
  # of neovim until plugins start to support 0.11.0
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
    unstable.ast-grep
    unstable.auto-cpufreq
    unstable.cargo
    unstable.copilot-language-server
    unstable.deskflow
    unstable.decktape
    unstable.harper
    unstable.fzf
    unstable.fzy
    unstable.gemini-cli
    unstable.i3status
    unstable.jupyter
    unstable.opencode
    unstable.poetry
    unstable.poppler
    unstable.pyrefly
    unstable.tree-sitter
    unstable.ruff
    unstable.rustc
    unstable.rustfmt
    unstable.uv
    unstable.ty
    unstable.picom
    unstable.zuban
    unstable.zoxide
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = unstable;
  };
}
