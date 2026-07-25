# Bootstrap — first-time install

Day-0 steps to get each machine onto this config. After the initial install,
everything runs through `just` (see the [README](../README.md)).

## macOS (macbook)

1. Install Nix (Determinate installer):
   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
2. Clone this repo and enter it:
   ```sh
   git clone <this-repo> ~/repos/nixos && cd ~/repos/nixos
   ```
3. Bootstrap nix-darwin (installs it and applies the config once):
   ```sh
   just bootstrap-darwin
   ```
4. From then on:
   ```sh
   just switch
   ```

> If you keep the Determinate daemon in charge of Nix, set `nix.enable = false`
> in `hosts/common/darwin.nix` (see the note there).

## NUC N100 (n100)

You can install directly on the box or remotely from the Mac.

### Option A — from the Mac with nixos-anywhere (recommended)

1. Boot the N100 into any Linux with SSH (the NixOS installer ISO works).
2. Confirm the target disk device and update `hosts/n100/disko.nix` if it is not
   `/dev/nvme0n1`.
3. From the Mac:
   ```sh
   nix run github:nix-community/nixos-anywhere -- \
       --flake .#n100 root@<n100-ip>
   ```
   This partitions with disko and installs in one shot.

### Option B — directly on the machine

1. Boot the NixOS installer ISO.
2. Partition with disko:
   ```sh
   sudo nix run github:nix-community/disko -- \
       --mode disko ./hosts/n100/disko.nix
   ```
3. Generate the real hardware profile (disko owns the filesystems):
   ```sh
   sudo nixos-generate-config --no-filesystems --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix hosts/n100/hardware-configuration.nix
   ```
4. Install and reboot:
   ```sh
   sudo nixos-install --flake .#n100
   reboot
   ```

### After install

- Add your SSH public key under `users.users.<name>.openssh.authorizedKeys.keys`
  in `hosts/common/nixos.nix`, then `just switch` (or `just deploy n100`).
