# macbook — Apple Silicon MacBook (nix-darwin).
{ ... }:
{
  networking.hostName = "macbook";
  networking.computerName = "macbook";

  # nix-darwin state version (integer). Bump only when release notes say to.
  system.stateVersion = 6;
}
