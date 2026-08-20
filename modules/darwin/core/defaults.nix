# macOS system defaults + primary user (applies to every darwin host).
{ username, ... }:
{
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  programs.zsh.enable = true; # register zsh as a login shell

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
}
