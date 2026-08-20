# AGENTS.md

Guidance for AI agents (and humans) working in this repository.

## What this is

A single Nix flake that declaratively manages three local machines. **There is no
NixOS in this repo.** Nix is used as a package manager and home-manager as the
config manager; nix-darwin adds a system layer on the Mac only.

- **macmini** — Apple Silicon M1 Mac mini (Macmini9,1, macOS 13 Ventura), via
  **nix-darwin + home-manager**
- **macbook** — Apple Silicon MacBook, via **nix-darwin + home-manager**. Shares
  everything with macmini by default
- **rpi5** — Raspberry Pi 5 with an M.2 HAT + NVMe, running stock **Raspberry Pi
  OS (64-bit)**, via **standalone home-manager** only. The OS, firmware, HAT
  PCIe settings and NVMe boot order are managed by hand, outside this repo.

This is the **base setup**: flake skeleton, shared home-manager, full lifecycle
(bootstrap → switch → update → gc), and CI. Application plugins and services are
added incrementally on top.

## Locked architectural decisions

| Decision | Choice | Notes |
|----------|--------|-------|
| Flake framework | **custom lib** (`nixpkgs.lib.extend`) | JManch-style; no flake-parts. Helpers live in `lib/`, threaded into modules via `specialArgs.lib` |
| macOS management | **nix-darwin + home-manager** | System + user, not home-manager-only |
| Linux management | **home-manager only** | No NixOS. Stock distro; Nix rides on top as a package manager. No `hosts/` entry for such a machine |
| Multi-Mac strategy | **share by default** | Shared config lives in `modules/darwin/` + `my.profiles.darwin`. `hosts/<mac>/` and `homes/<mac>.nix` hold only per-machine deltas |
| Secrets | **Deferred** | No sops/agenix yet. Add an input + `modules/**` when a service needs it |
| Lifecycle tooling | **justfile** | See `justfile`; not `nix run` apps |
| nixpkgs channel | **nixos-25.05** (stable) + `nixpkgs-unstable` overlay | `pkgs.unstable.<name>` for bleeding-edge packages |

Reference repo this was modeled on: `xluffy/nix-config` (home-manager-only) for
the Linux side, plus `JManch/nixos` for the custom-lib module layout.

## Repo map

```
flake.nix            inputs + outputs; declares machines, devShell, formatter
lib/default.nix      custom lib: mkDarwin / mkHome / forAllSystems + overlays
modules/             per-concern modules, auto-imported (default.nix scans the tree)
  darwin/            system modules, shared by every Mac
    core/            nix, defaults, identity (unconditional); fonts, rosetta (toggles)
    programs/        homebrew: shared baseline + my.darwin.homebrew.{taps,brews,casks}
  home-manager/      home modules (cross-platform for the user)
    core/            home, git, packages (unconditional)
    programs/        direnv, shell/zsh, editors/{vscode,ideavim} (toggles)
    profiles/
      darwin.nix     shared Mac home profile (my.profiles.darwin.enable)
      darwin/        vendored Mac dotfiles: zsh theme/plugin, vscode, ideavimrc
hosts/               system-layer config; darwin only
  macmini/           stateVersion + per-machine toggles and brew extras
  macbook/           same shape; shared baseline only for now
homes/
  macmini.nix        enables my.profiles.darwin + machine-specific packages
  macbook.nix
  rpi5.nix           standalone home — the machine's entire config
overlays/default.nix custom package overlay — empty stub
docs/bootstrap.md    first-time install per machine
justfile             lifecycle commands
.github/workflows/   CI: nix flake check + per-machine build matrix
```

## Conventions

- **Module namespace is `my`.** Feature modules declare
  `options.my.<path>.enable = lib.mkEnableOption "..."` and wrap config in
  `lib.mkIf cfg.enable {...}`. Core modules (things every host needs) apply
  unconditionally with no toggle. Hosts/homes just flip `my.*.enable` (+ set any
  module options). This is the JManch-style pattern.
- **Modules are auto-imported.** `modules/{darwin,home-manager}/default.nix`
  recursively imports every `*.nix` (except `default.nix`) via
  `lib.filesystem.listFilesRecursive`. Just drop a new file in the right folder —
  no import list to maintain. macOS system modules go under `darwin/`; home
  modules (anything cross-platform, and everything the Pi gets) under
  `home-manager/`.
- **Two Macs share by default.** Anything true of "a Mac" belongs in
  `modules/darwin/` (system) or `modules/home-manager/profiles/darwin.nix`
  (user), NOT copied into both host files. Only a genuine per-machine difference
  justifies a line in `hosts/<mac>/` or `homes/<mac>.nix`. Vendored Mac dotfiles
  live in `modules/home-manager/profiles/darwin/` because both Macs use them —
  the "no host data in shared modules" rule doesn't apply once it isn't host data.
- **Hostname is derived**, not written down: `modules/darwin/core/identity.nix`
  sets `networking.hostName` from the `hostname` specialArg, which mkDarwin takes
  from the flake attribute name. Don't set it in host files.
- **Homebrew is additive.** `modules/darwin/programs/homebrew.nix` holds the
  shared lists; a host appends with `my.darwin.homebrew.{taps,brews,casks}`. Never
  redefine `homebrew.brews` directly in a host file — that drops the baseline.
- **Add a machine:** with a system layer (macOS), create `hosts/<name>/` +
  `homes/<name>.nix` and add a `mkDarwin` line under `outputs` in `flake.nix`.
  home-manager-only, create just `homes/<name>.nix` and add a `mkHome` line —
  **no `hosts/` entry**, since there is no system to configure. Builders live in
  `lib/default.nix`; don't hand-roll `darwinSystem`/`homeManagerConfiguration`
  elsewhere.
- **Machine-specific data** (package lists, vendored config files) lives in
  `hosts/<name>/` or `homes/<name>.nix`, not in shared modules.
- **New lib helpers** go in `lib/default.nix` (`lib.<name>`, available in modules).
- **specialArgs** in system + home modules: `inputs`, `self`, `lib` (extended),
  `username`, `hostname`.
- **home-manager runs two ways.** On macmini it is a nix-darwin system module
  (`useGlobalPkgs`, `useUserPackages`), so `home.username`/`homeDirectory` come
  from the system user. On rpi5 it is standalone, and `lib.mkHome` sets those two
  explicitly. Either way, **don't set them in `modules/` or `homes/`.**
- **Nothing in `modules/home-manager/` may assume a system layer** — it has to
  evaluate on a machine where Nix owns nothing but the user's profile. Anything
  needing root (login shell, services, firmware) is a manual OS step, documented
  in `docs/bootstrap.md`.
- **Formatting:** `nix fmt` (nixfmt-tree, recurses the repo). Run before committing.
- Prefer `pkgs.unstable.<pkg>` over bumping the whole channel for one package.

## macOS package/service policy (macmini, macbook)

Reproduced from the user's dotfiles `SETUP.md` and the live macmini.

- **GUI apps + macOS-integration/service formulae** → Homebrew, via
  `modules/darwin/programs/homebrew.nix` (`my.darwin.homebrew.enable`). Casks
  (iterm2, raycast, stats, vscode, rectangle, bitwarden, podman-desktop, ...) and
  CLIs awkward in nixpkgs-on-darwin (blueutil, displayplacer, mole) are in the
  shared baseline. macmini additionally takes the always-on services
  (postgresql@14, unbound) and pgadmin4 via its host file.
  `onActivation.cleanup = "none"` — nothing gets uninstalled; safe while migrating.
- **Portable CLI tools** → home-manager (`modules/home-manager/core/packages.nix`).
  Migrate brew CLIs here over time, then drop them from `homebrew.brews`.
- **node** is managed by **nvm** (`~/.nvm`), **not** nix — `homes/macmini.nix`
  sets `my.programs.zsh.initExtra` to lazy-load nvm. Do not add nodejs via nix.
- **Shell**: the reusable module is `modules/home-manager/programs/shell/zsh.nix`
  (`my.programs.zsh.enable` + theme/plugins/customDir/initExtra options). The Mac
  profile sets theme `pi` and plugins per SETUP.md; the `pi` theme and `cmdtime`
  plugin are **vendored** under `profiles/darwin/zsh/` (no network/hash). The
  profile owns `initExtra` (nvm lazy-load) — per-machine shell additions go
  through `my.profiles.darwin.zshExtra` so they append instead of colliding.
  First switch backs up the existing `~/.zshrc` as `~/.zshrc.hm-bak`.
- **Editors**: modules `programs/editors/{vscode,ideavim}.nix` take a source path;
  the actual configs are vendored under `profiles/darwin/{vscode,ideavimrc}`.
  VSCode's `settings.json` becomes a read-only store symlink — edit it in-repo.
- **Fonts / Rosetta**: `my.darwin.fonts.enable` (Monaspace) and
  `my.darwin.rosetta.enable` toggled in `hosts/macmini/default.nix`; logic in
  `modules/darwin/core/{fonts,rosetta}.nix`.

## Raspberry Pi 5 policy (rpi5)

- **`homes/rpi5.nix` is the entire config.** There is no `hosts/rpi5/`.
- **Out of scope for Nix**, done by hand once and documented in
  `docs/bootstrap.md`: the M.2 HAT's PCIe settings (`dtparam=pciex1` in
  `/boot/firmware/config.txt`), the EEPROM `BOOT_ORDER` for NVMe boot, firmware
  updates, apt packages, systemd units, and the login shell. Don't try to move
  any of these into the flake — they are below the layer home-manager operates
  at.
- The username in `flake.nix` must match the real Linux user; `homeDirectory`
  defaults to `/home/<username>` and is overridable via `mkHome`.

## State versions — do not change casually

- `modules/home-manager/core/home.nix`: `home.stateVersion = "25.05"`
- `hosts/{macmini,macbook}/default.nix`: `system.stateVersion = 6` (nix-darwin, integer)

## Open TODOs (fill in before first real switch)

- Confirm the macbook is Apple Silicon — if Intel, set `system = "x86_64-darwin"`
  in its `mkDarwin` call, add that to `systems` in `lib/default.nix`, drop the
  rosetta toggle, and move it off the `macos-latest` CI runner
- Split the shared brew lists further once the macbook's real needs are known —
  right now it inherits everything except postgresql@14/unbound/pgadmin4
- Confirm the rpi5 Linux username matches `flake.nix` (currently `rnvo`)
- Add an SSH host alias `rpi5` (used by `just deploy-rpi5`), or pass a host arg
- `homes/rpi5.nix` is a starting point — no services on the Pi yet

## Verification

1. `nix flake check` — evaluates both Macs + formatting. **Note it silently
   ignores `homeConfigurations`**, so it does not cover rpi5.
2. `nix build .#darwinConfigurations.{macmini,macbook}.system` (on macOS)
3. `nix build .#homeConfigurations.rpi5.activationPackage` (needs aarch64-linux)
4. `just fmt` / `just check` clean
5. Apply with `just switch`; confirm a home-manager tool (e.g. `eza`) is on PATH
