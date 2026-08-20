# Manage VSCode user settings.json (VSCode itself is installed via cask).
# NOTE: the linked file is a read-only store symlink, so editing settings from
# the VSCode UI fails — change `settingsSource` in-repo and re-switch.
{ config, lib, ... }:
let
  cfg = config.my.programs.vscode;
in
{
  options.my.programs.vscode = {
    enable = lib.mkEnableOption "VSCode user settings management";
    settingsSource = lib.mkOption {
      type = lib.types.path;
      description = "Path to a settings.json to symlink into VSCode's user dir.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file."Library/Application Support/Code/User/settings.json".source = cfg.settingsSource;
  };
}
