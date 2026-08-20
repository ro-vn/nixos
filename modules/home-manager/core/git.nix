# Git identity and defaults.
{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Ro Vo";
    userEmail = "ngocro208@gmail.com";
    extraConfig.core.editor = "vi";
  };
}
