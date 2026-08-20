# Desktop fonts. Enable per-host with `my.darwin.fonts.enable = true`.
{ config, lib, pkgs, ... }:
let
  cfg = config.my.darwin.fonts;
in
{
  options.my.darwin.fonts.enable = lib.mkEnableOption "curated desktop fonts (Monaspace)";

  config = lib.mkIf cfg.enable {
    fonts.packages = [ pkgs.monaspace ];
  };
}
