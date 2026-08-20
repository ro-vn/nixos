# Manage the IdeaVim config (~/.ideavimrc).
{ config, lib, ... }:
let
  cfg = config.my.programs.ideavim;
in
{
  options.my.programs.ideavim = {
    enable = lib.mkEnableOption "IdeaVim configuration";
    source = lib.mkOption {
      type = lib.types.path;
      description = "Path to a .ideavimrc to symlink into $HOME.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".ideavimrc".source = cfg.source;
  };
}
