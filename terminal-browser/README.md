# terminal-browser on NixOS

Makes the [terminal-browser](https://terminal-browser.sh/) bundle — installed
via its upstream script — actually run on NixOS.

## Status: superseded by nix-ld

`configuration.nix` now sets `programs.nix-ld.libraries` to the same library set
this directory pins (nixpkgs' `electron-unwrapped` RPATH), so unpatched Electron
binaries resolve those libraries through `nix-ld` itself. The shim is therefore
redundant — it is kept only as a fallback, and can be dropped with

```bash
~/configure/nixos/terminal-browser/de-shim.sh
```

That script checks that the real binary loads through `nix-ld` on its own
(`LD_LIBRARY_PATH` cleared) and refuses to remove the shim if it does not, so it
is safe to run at any time. With the shim gone, upstream upgrades need no
re-apply at all.

The rest of this file documents the shim approach for the case where `nix-ld` is
not in use, or is missing an entry.

## The problem

terminal-browser's install script (`curl -fsSL https://terminal-browser.sh/install | bash`)
downloads the CLI plus a **bundled Electron binary** that is built for generic
distro Linux. That binary expects glibc-style system libraries in `/usr/lib`
(`libglib-2.0.so.0`, `libgtk-3.so.0`, `libnss3.so`, ... — 27 shared libraries
on this system), provided by `apt-get` / `dnf` on normal distros.

NixOS does **not** ship a `/usr/lib`. Nothing provides those libraries to a
dynamically linked binary that was not built by nixpkgs:

```
$ ~/.local/share/terminal-browser/app/electron/electron --version
error while loading shared libraries: libglib-2.0.so.0: cannot open shared object file
```

The upstream script's `sudo apt-get install ...` step can never work on NixOS —
that is expected and harmless; the CLI installs anyway, and only the bundled
Electron fails at runtime.

## How the fix works

Three parts glue the upstream install to NixOS — all user-space, no system
rebuild, no flakes, no unfree packages:

1. **`electron-rpath.txt` — the exact library set.**
   Extracted from the embedded RPATH of nixpkgs' own `electron-unwrapped`
   package (`patchelf --print-rpath`). This is the canonical, version-consistent
   set of libraries a Chromium/Electron binary needs on this machine (glib,
   gtk3, nss, nspr, cups, dbus, alsa, mesa/libgbm, the X libraries, ...).

2. **`electron-libs.nix` — one merged store path.**
   A `stdenv.mkDerivation` that symlinks the contents of all those store
   directories into a single output's `lib/`. Two deliberate details make the
   sandboxed build succeed:
   - each directory is wrapped in `builtins.storePath`, so the strings carry
     real store-path reference context and every directory becomes a declared
     **input** of the derivation (only declared inputs are mounted in the build
     sandbox);
   - `stdenv.mkDerivation` is used instead of `runCommand` because
     `runCommand` externalizes `buildCommand` via `passAsFile`, which hides
     those references from the input scanner.

3. **A shim + a GC root.**
   The real binary is kept as `app/electron/<name>.real` and
   `app/electron/<name>` becomes a ~10-line wrapper that exports
   `LD_LIBRARY_PATH=<merged libs>/lib` and execs the real binary. The merged
   libs store path is registered as a GC root at
   `~/.gcroots/terminal-browser-libs` so `nix-collect-garbage` never deletes it.

`<name>` is the bundled Electron entry binary the CLI execs: `pixel` since
v0.11.1, `electron` before that. The installer detects which one is present
(a file that is already one of our shims does not count), so an upstream rename
needs no script change.

The shim sits at the exact path the CLI hard-codes for both node-mode
(CLI runner) and browser-window launches, so a single shim covers everything.

## Layout

```
terminal-browser/
├── README.md                        # this file
├── install-terminal-browser.sh      # bootstrap + reapply (idempotent)
├── de-shim.sh                       # remove the shim (nix-ld now covers this)
├── electron-libs.nix                # merges the library set into one store path
└── electron-rpath.txt               # the pinned library set (store dirs)
```

Runtime artifacts on the machine:

```
~/.local/bin/terminal-browser                          # the CLI (upstream)
~/.local/share/terminal-browser/app/electron/pixel  # shim (ours)
~/.local/share/terminal-browser/app/electron/pixel.real  # real Electron
~/.gcroots/terminal-browser-libs                       # GC root -> merged libs
~/.local/share/terminal-browser/reapply-electron-shim.sh  # delegates to repo script
```

## Install from scratch

Prereqs: a working `nix` environment on NixOS with the `nixpkgs` channel
(having the `electron` package available also enables automatic regeneration
of `electron-rpath.txt`, see below).

```bash
cd ~/configure/nixos/terminal-browser
./install-terminal-browser.sh
```

The script is **idempotent** — running it again is a no-op. It will:

1. install the CLI via the upstream script if missing (the `apt-get` step
   failing is expected);
2. build the merged libs store path from `electron-libs.nix`;
3. register the GC root;
4. install the shim (or verify it is already in place);
5. print `terminal-browser v0.7.0` (or whatever version) as a sanity check.

## After an upgrade

`terminal-browser upgrade` re-downloads the bundle and replaces the whole
`app/` tree, clobbering the shim (and with it any `*.real`).
Re-apply it with:

```bash
~/configure/nixos/terminal-browser/install-terminal-browser.sh --reapply
# or, from the runtime dir:
~/.local/share/terminal-browser/reapply-electron-shim.sh
```

`--reapply` restores the shim even if the upgrade either wiped the whole
`app/` directory or only overwrote the Electron binary in place (any stale
`<name>.real` is discarded first, so the shim always execs the fresh binary,
and a shim left under the other upstream name is removed).

## When the pinned library set goes stale

`electron-rpath.txt` pins store paths from one nixpkgs revision. They cannot
disappear on this machine (the GC root keeps them alive), and they are always
version-consistent with the running system. If you ever move to a new machine
or major channel bump where the paths no longer exist, the script detects it
(`every store dir must exist`) and regenerates the file from the *current*
`electron-unwrapped` RPATH:

```bash
# if the saved set is invalid, plain bootstrap regenerates it automatically
./install-terminal-browser.sh
```

## Uninstall

```bash
# remove the shim (restore the real binary)
rm ~/.local/share/terminal-browser/app/electron/pixel
mv ~/.local/share/terminal-browser/app/electron/pixel.real \
   ~/.local/share/terminal-browser/app/electron/pixel

# drop the GC root; the merged libs become collectable garbage
rm ~/.gcroots/terminal-browser-libs

# remove the CLI (and optionally the whole app dir)
rm ~/.local/bin/terminal-browser
rm -rf ~/.local/share/terminal-browser

# then optionally: nix-collect-garbage -d   (removes the merged libs)
```

## Troubleshooting

- **Sandbox error at first `open`** (`SUID sandbox helper ... or
  unprivileged user namespaces`): the bundled `chrome-sandbox` is not setuid.
  NixOS kernels normally allow unprivileged user namespaces, which Chromium
  falls back to. If yours does not, launch with
  `ELECTRON_DISABLE_SANDBOX=1 terminal-browser open <url>` as a stopgap.
- **`libstdc++` missing**: the pinned set includes `gcc-*-lib` from the same
  nixpkgs revision; if you regenerate `electron-rpath.txt` on an older channel
  and `ldd` complains, re-run `nix-shell -p electron patchelf --run
  'patchelf --print-rpath ...'` against the current channel's unwrapped binary.
- **Terminal/agent integration** works because the CLI itself (`~/.local/bin/
  terminal-browser`) is a plain shell launcher — nothing NixOS-specific about
  it — and the shim covers the Electron it spawns.

## Notes / alternatives

- terminal-browser is **not packaged in nixpkgs** (checked 2026-08), so there
  is no `environment.systemPackages` entry for it yet; this repo keeps the
  state that makes the community installer work.
- A "proper" alternative would be a `buildFHSEnv` wrapper in
  `configuration.nix` (a few-hundred-MB resolved closure, needs a rebuild, and
  the `steam-run` variant additionally requires `allowUnfree`). The approach
  here needs no config changes and no rebuild.