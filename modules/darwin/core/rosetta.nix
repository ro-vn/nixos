# Install Rosetta 2 on activation if missing. Enable per-host with
# `my.darwin.rosetta.enable = true`. `oahd` is the Rosetta daemon.
{ config, lib, ... }:
let
  cfg = config.my.darwin.rosetta;
in
{
  options.my.darwin.rosetta.enable = lib.mkEnableOption "automatic Rosetta 2 install";

  config = lib.mkIf cfg.enable {
    # nix-darwin only exposes fixed activation-script hooks; use postActivation.
    system.activationScripts.postActivation.text = ''
      if ! /usr/bin/pgrep -q oahd; then
        echo "Installing Rosetta 2..."
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
      fi
    '';
  };
}
