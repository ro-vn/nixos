# macmini home. The shared Mac profile (zsh, editors, direnv, vendored dotfiles)
# is in modules/home-manager/profiles/darwin.nix; only machine-specific things
# belong here.
{ pkgs, ... }:
{
  my.profiles.darwin.enable = true;

  home.packages = [ pkgs.temurin-bin-21 ]; # Java (Adoptium Temurin LTS)
}
