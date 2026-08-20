# zsh + oh-my-zsh. Enable and tune per-host, e.g.:
#   my.programs.zsh = {
#     enable = true;
#     theme = "pi";
#     plugins = [ "git" "node" "autojump" ];
#   };
{ config, lib, ... }:
let
  cfg = config.my.programs.zsh;
in
{
  options.my.programs.zsh = {
    enable = lib.mkEnableOption "zsh with oh-my-zsh";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "robbyrussell";
      description = "oh-my-zsh theme name.";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "git" ];
      description = "oh-my-zsh plugins to enable.";
    };

    customDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "ZSH_CUSTOM dir holding custom themes/plugins (absolute path).";
    };

    initExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines appended to .zshrc.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true; # zsh-autosuggestions
      syntaxHighlighting.enable = true; # zsh-syntax-highlighting
      oh-my-zsh = {
        enable = true;
        theme = cfg.theme;
        plugins = cfg.plugins;
      } // lib.optionalAttrs (cfg.customDir != null) { custom = cfg.customDir; };
      initContent = cfg.initExtra;
    };
  };
}
