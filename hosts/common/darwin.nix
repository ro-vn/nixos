# Defaults for every darwin host (currently just the macbook).
{ username, ... }:
{
  # Let nix-darwin manage the nix daemon configuration. If you installed Nix
  # with the Determinate installer and prefer it to own the daemon, set this to
  # false and drop `nix.settings` from hosts/common/shared.nix.
  nix.enable = true;

  system.primaryUser = username;

  users.users.${username}.home = "/Users/${username}";

  programs.zsh.enable = true;

  system.defaults = {
    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
    };
    finder = {
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv";
    };
    dock = {
      autohide = true;
      show-recents = false;
    };
  };

  nix.gc = {
    automatic = true;
    interval.Day = 7;
    options = "--delete-older-than 14d";
  };
}
