# Bootstrap — first-time install

Day-0 steps to get each machine onto this config. After the initial install,
everything runs through `just` (see the [README](../README.md)).

## macOS (macmini, macbook)

Identical for both Macs — only the flake attribute differs.

1. Install Nix (Determinate installer):
   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
2. Clone this repo and enter it:
   ```sh
   git clone <this-repo> ~/repos/nixos && cd ~/repos/nixos
   ```
3. Bootstrap nix-darwin (installs it and applies the config once). The machine's
   hostname is still the macOS default at this point, so name the host:
   ```sh
   just bootstrap-darwin macmini    # or: just bootstrap-darwin macbook
   ```
   This sets `LocalHostName` to match, via `modules/darwin/core/identity.nix`.
4. From then on the hostname resolves the flake attribute automatically:
   ```sh
   just switch
   ```
   Pass a name (`just switch macbook`) to override.

> If you keep the Determinate daemon in charge of Nix, set `nix.enable = false`
> in `modules/darwin/core/nix.nix` (see the note there).

> Both Macs share `modules/darwin/` and the `my.profiles.darwin` home profile.
> Anything only one machine needs goes in `hosts/<name>/default.nix` (system,
> incl. `my.darwin.homebrew.{taps,brews,casks}`) or `homes/<name>.nix` (user).

## Raspberry Pi 5 (rpi5)

This machine has **no system layer in this repo**. The OS is stock Raspberry Pi
OS (64-bit) and home-manager only manages the user's packages and dotfiles.

### Prerequisites — not managed by Nix

The M.2 HAT and NVMe drive are firmware/OS concerns. Do these once, by hand, on
the Pi; nothing below is declared anywhere in this flake.

1. Update the firmware and EEPROM first: `sudo rpi-eeprom-update -a`, reboot.
2. Enable the PCIe link the HAT sits on, in `/boot/firmware/config.txt`:
   ```
   dtparam=pciex1
   dtparam=pciex1_gen=3    # Gen 3 is out of spec but works on most HAT+NVMe combos
   ```
3. To boot from the NVMe, set the boot order to try NVMe first — either
   `sudo raspi-config` → *Advanced Options* → *Boot Order* → *NVMe*, or
   `sudo rpi-eeprom-config --edit` and set `BOOT_ORDER=0xf416`.
4. Reboot and confirm the drive is there: `lsblk`, `sudo nvme list`.
   (`nvme-cli`, `smartmontools` and `pciutils` come from `homes/rpi5.nix` once
   home-manager is active — before that, use the apt versions.)

### Install

1. Install Nix (multi-user; Raspberry Pi OS is systemd, so this works as-is):
   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
   Log out and back in so the daemon and profile are on `PATH`.
2. Clone this repo:
   ```sh
   git clone <this-repo> ~/repos/nixos && cd ~/repos/nixos
   ```
3. First activation — there is no `home-manager` binary yet, so run it via `nix run`:
   ```sh
   just bootstrap-home
   ```
   This backs up any conflicting dotfile (e.g. `~/.zshrc`) as `*.hm-bak`.
4. From then on, on the Pi:
   ```sh
   just switch
   ```
   or from the Mac: `just deploy-rpi5`.

### Notes

- The username in `flake.nix` (`rnvo`) must match the actual Linux user, and
  `homeDirectory` defaults to `/home/<username>`. Override with the
  `homeDirectory` argument to `mkHome` if it differs.
- zsh is configured by home-manager but **not** set as the login shell — that is
  a system change: `chsh -s $(which zsh)`.
- `just deploy-rpi5` assumes an SSH host alias `rpi5` and that the repo is at
  `~/repos/nixos` on the Pi.
