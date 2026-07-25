# treefmt-nix drives `nix fmt` and provides the formatting check in CI.
{ ... }:
{
  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
    };
  };
}
