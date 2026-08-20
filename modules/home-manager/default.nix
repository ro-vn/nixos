# Auto-imports every home-manager module file in this tree (except default.nix).
{ lib, ... }:
{
  imports = builtins.filter (
    p: lib.hasSuffix ".nix" (baseNameOf p) && baseNameOf p != "default.nix"
  ) (lib.filesystem.listFilesRecursive ./.);
}
