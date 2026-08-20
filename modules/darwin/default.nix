# Auto-imports every module file in this tree (except default.nix files).
{ lib, ... }:
{
  imports = builtins.filter (
    p: lib.hasSuffix ".nix" (baseNameOf p) && baseNameOf p != "default.nix"
  ) (lib.filesystem.listFilesRecursive ./.);
}
