# PLACEHOLDER hardware profile for the N100.
#
# Regenerate this on the actual machine during install with:
#   sudo nixos-generate-config --no-filesystems --root /mnt
# (--no-filesystems because disko.nix already declares the filesystems).
#
# The values below are sane defaults for a typical Intel N100 mini PC with an
# NVMe disk, enough to evaluate the flake before you have the hardware.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
