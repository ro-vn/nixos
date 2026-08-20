# macmini — Apple Silicon M1 Mac mini (Macmini9,1), nix-darwin.
#
# Shared Mac config lives in modules/darwin/; this file is only what is true of
# *this* machine. hostname/computerName come from the `hostname` specialArg via
# modules/darwin/core/identity.nix.
{ ... }:
{
  my.darwin.fonts.enable = true; # Monaspace (SETUP.md)
  my.darwin.rosetta.enable = true; # Rosetta 2 (SETUP.md)

  my.darwin.homebrew = {
    enable = true;

    # Always-on box, so it hosts the local database + DNS resolver.
    brews = [
      "postgresql@14"
      "unbound"
    ];
    casks = [ "pgadmin4" ];
  };

  # nix-darwin state version (integer). Bump only when release notes say to.
  system.stateVersion = 6;
}
