# Home-manager baseline, shared by every home. Don't set username/homeDirectory
# here: on darwin they come from the system user, and for standalone homes
# `lib.mkHome` sets them. Only the state version is pinned.
{ ... }:
{
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
