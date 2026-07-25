# Defaults for every NixOS host (currently just the n100).
{ username, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles"; # TODO: confirm timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # Headless box: manage it over SSH.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    # TODO: add your SSH public key so you can log in / deploy remotely.
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... you@host" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
