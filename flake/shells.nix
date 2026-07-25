# Development shell: the tools you need to work on this repo.
#   nix develop   (or automatically via direnv)
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          nixfmt-rfc-style
          nil # nix language server
          git
        ];
      };
    };
}
