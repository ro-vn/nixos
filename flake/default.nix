# flake-parts entrypoint. Imports the per-concern modules and declares the
# systems we build for. Host definitions live in ./hosts.nix.
{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./hosts.nix
    ./shells.nix
    ./formatter.nix
  ];

  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
