# n100 — Intel N100 mini PC (NixOS, headless).
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "n100";

  # NixOS state version — do not change after install.
  system.stateVersion = "25.05";
}
