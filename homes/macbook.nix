# macbook home. The shared Mac profile (zsh, editors, direnv, vendored dotfiles)
# is in modules/home-manager/profiles/darwin.nix; only machine-specific things
# belong here.
#
# Machine-specific shell additions go through `my.profiles.darwin.zshExtra`
# rather than `my.programs.zsh.initExtra`, which the profile already owns.
{ ... }:
{
  my.profiles.darwin.enable = true;
}
