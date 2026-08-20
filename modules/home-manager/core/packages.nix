# Core CLI tools available on every host.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    tree
  ];
}
