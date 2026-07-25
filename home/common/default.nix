# Shared home-manager configuration — the "homes" layer used by every machine.
# username / homeDirectory are set automatically by the system-level
# home-manager module (useUserPackages), so we don't set them here.
{ pkgs, ... }:
{
  imports = [
    # Reusable home-manager modules land here as the setup grows:
    # ../../modules/home
  ];

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    tree
  ];

  programs.git = {
    enable = true;
    userName = "Ro Vo";
    userEmail = "ngocro208@gmail.com";
  };

  programs.zsh.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
