# direnv + nix-direnv. Enable with `my.programs.direnv.enable = true`.
{ config, lib, ... }:
let
  cfg = config.my.programs.direnv;
in
{
  options.my.programs.direnv.enable = lib.mkEnableOption "direnv with nix-direnv";

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
