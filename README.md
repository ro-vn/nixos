# nixos

Nix configuration for my local machines. No NixOS here — Nix is used as a
**package manager** and home-manager as the **config manager**, with nix-darwin
adding a system layer on the Macs only.

- **macmini** — Apple Silicon M1 Mac mini, [nix-darwin] + [home-manager]
- **macbook** — Apple Silicon MacBook, [nix-darwin] + [home-manager]
- **rpi5** — Raspberry Pi 5 (M.2 HAT + NVMe) on stock Raspberry Pi OS,
  [home-manager] only

The two Macs share everything by default: `modules/darwin/` for the system layer
and the `my.profiles.darwin` home profile for `$HOME`. A host file only carries
what is true of that one machine.

Built with a custom `lib` (via `nixpkgs.lib.extend`). Application plugins and
services are added incrementally.

## Layout

```
flake.nix            inputs + outputs; declares machines, devShell, formatter
lib/default.nix      custom lib: mkDarwin / mkHome / forAllSystems + overlays
modules/             per-concern modules, auto-imported by each default.nix
  darwin/            darwin system modules, shared by every Mac
    core/            nix, defaults, identity (unconditional); fonts, rosetta
    programs/        homebrew (shared baseline + per-host extras)
  home-manager/      home modules
    core/            home, git, packages (unconditional)
    programs/        shell/zsh, editors/{vscode,ideavim}, direnv (toggles)
    profiles/        darwin.nix — the shared Mac home profile
    profiles/darwin/ vendored Mac dotfiles: zsh theme/plugin, vscode, ideavimrc
hosts/               system layer; darwin only
  macmini/           machine-specific toggles + extra brews/casks
  macbook/
homes/
  macmini.nix        enables the Mac profile + machine-specific packages
  macbook.nix
  rpi5.nix           standalone home; no hosts/ entry — this is the whole config
overlays/            custom package overlay — stub for now
docs/bootstrap.md    first-time install steps
justfile             lifecycle commands
.github/workflows/   CI (flake check + per-machine build matrix)
```

Modules follow a `my.*` namespace: feature modules expose `my.<x>.enable`
toggles; hosts and homes flip them. New modules are picked up automatically —
just drop a file in the right folder.

## Lifecycle

Enter the dev shell (`nix develop`, or via direnv) to get `just`:

| Command | What it does |
|---------|--------------|
| `just switch` | Build + activate the current machine |
| `just build` | Build without activating |
| `just switch macbook` | Target a specific Mac explicitly |
| `just deploy-rpi5` | Pull + apply the home config on the Pi over SSH |
| `just update` | Update flake inputs |
| `just check` | Evaluate the flake |
| `just fmt` | Format all Nix files |
| `just gc` | Garbage-collect old generations |

First-time install: see [docs/bootstrap.md](docs/bootstrap.md).

Note `nix flake check` ignores `homeConfigurations` (not a standard flake
output), so `just check` does **not** verify the Pi. Use `just build` on the Pi,
or `nix build .#homeConfigurations.rpi5.activationPackage`.

## Adding a machine

- **Another Mac:** create `hosts/<name>/default.nix` (state version + whatever
  differs) and `homes/<name>.nix` (`my.profiles.darwin.enable = true;`), then add
  a `mkDarwin` line under `outputs` in `flake.nix`. Hostname is derived from the
  attribute name, so there is nothing else to wire up.
- **home-manager only:** create `homes/<name>.nix` and add a `mkHome` line. No
  `hosts/` entry — there is no system to configure.

[nix-darwin]: https://github.com/nix-darwin/nix-darwin
[home-manager]: https://github.com/nix-community/home-manager
