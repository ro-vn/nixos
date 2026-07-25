# Declares the machines. The heavy lifting (module wiring, home-manager,
# overlays) lives in ../lib. Add a new machine by adding a directory under
# ../hosts and one line here.
{ inputs, self, ... }:
let
  helpers = import ../lib { inherit inputs self; };
  inherit (helpers) mkDarwin mkNixos;
in
{
  flake.darwinConfigurations.macbook = mkDarwin {
    hostname = "macbook";
    username = "rnvo";
  };

  flake.nixosConfigurations.n100 = mkNixos {
    hostname = "n100";
    username = "rnvo";
    system = "x86_64-linux";
  };
}
