# nixos

Unified Nix configuration for my local machines:

- **macbook** — Apple Silicon MacBook, managed with [nix-darwin] + [home-manager]
- **n100** — Intel N100 mini PC, managed with NixOS + [home-manager]

Built on [flake-parts]. This is the **base setup** — full lifecycle, CI, and
shared home-manager. Application plugins and services are added incrementally.

## Layout

```
flake.nix            inputs + flake-parts entrypoint
flake/               flake-parts modules (hosts, dev shell, formatter)
lib/                 mkDarwin / mkNixos host builders
hosts/
  common/            config shared across hosts (shared, nixos, darwin)
  macbook/           darwin host
  n100/              nixos host (+ disko + hardware profile)
home/
  common/            shared home-manager ("homes" layer)
  macbook.nix        per-host home
  n100.nix
modules/             reusable modules (nixos / darwin / home) — stubs for now
overlays/            custom package overlay — stub for now
docs/bootstrap.md    first-time install steps
justfile             lifecycle commands
.github/workflows/   CI (flake check + per-host build matrix)
```

## Lifecycle

Enter the dev shell (`nix develop`, or via direnv) to get `just`:

| Command | What it does |
|---------|--------------|
| `just switch` | Build + activate the current machine |
| `just build` | Build without activating |
| `just deploy n100` | Deploy a NixOS host over SSH from the Mac |
| `just update` | Update flake inputs |
| `just check` | Evaluate the whole flake |
| `just fmt` | Format all Nix files |
| `just gc` | Garbage-collect old generations |

First-time install: see [docs/bootstrap.md](docs/bootstrap.md).

## Adding a machine

1. Create `hosts/<name>/` (and a `home/<name>.nix`).
2. Add one line in `flake/hosts.nix` using `mkNixos` or `mkDarwin`.

[nix-darwin]: https://github.com/nix-darwin/nix-darwin
[home-manager]: https://github.com/nix-community/home-manager
[flake-parts]: https://flake.parts
