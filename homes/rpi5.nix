# rpi5 — Raspberry Pi 5 (aarch64) with an M.2 HAT + NVMe drive.
#
# This host has NO system layer in this repo. The OS is stock Raspberry Pi OS,
# and Nix is installed on top purely as a package manager; home-manager manages
# this user's packages and dotfiles. Anything below the user level — the HAT's
# PCIe settings, the NVMe boot order, apt packages, systemd units — is the OS's
# job and is documented in docs/bootstrap.md, not declared here.
{ pkgs, ... }:
{
  my.programs.direnv.enable = true;

  my.programs.zsh = {
    enable = true;
    plugins = [
      "git"
      "sudo"
    ];
  };

  # Headless box: monitoring + the tooling to inspect the NVMe behind the HAT.
  home.packages = with pkgs; [
    htop
    nvme-cli
    smartmontools
    pciutils
    rsync
  ];
}
