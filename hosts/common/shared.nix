# Configuration shared by every host, NixOS and darwin alike.
{ username, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      username
    ];
    auto-optimise-store = true;
    warn-dirty = false;
  };

  nixpkgs.config.allowUnfree = true;
}
