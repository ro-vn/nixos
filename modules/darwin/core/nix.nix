# Core Nix daemon settings + GC (applies to every darwin host).
# If you keep the Determinate installer in charge of the daemon, set
# `nix.enable = false` and remove `nix.settings` below.
{ username, ... }:
{
  nix.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      username
    ];
    warn-dirty = false;
  };

  nix.gc = {
    automatic = true;
    interval.Day = 7;
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;
}
