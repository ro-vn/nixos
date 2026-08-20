# Shared Mac home profile — everything both Macs want in $HOME.
#
# Enable with `my.profiles.darwin.enable = true` in homes/<host>.nix, then add
# only genuinely machine-specific bits (extra packages, per-machine overrides)
# alongside it. Vendored dotfiles live in ./darwin/ next to this module because
# they are shared by every Mac; anything that is true of only one machine does
# not belong here.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.profiles.darwin;
in
{
  options.my.profiles.darwin = {
    enable = lib.mkEnableOption "shared Mac home profile (zsh, editors, direnv)";

    zshExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Machine-specific lines appended after the shared .zshrc content.";
    };
  };

  config = lib.mkIf cfg.enable {
    my.programs.direnv.enable = true;

    # zsh + oh-my-zsh, reproduced from SETUP.md.
    my.programs.zsh = {
      enable = true;
      theme = "pi"; # tobyjamesthomas/pi (vendored below)
      plugins = [
        "git"
        "node"
        "autojump" # requires the `autojump` brew formula
        "cmdtime" # tom-auger/cmdtime (vendored below)
      ];
      customDir = "${config.home.homeDirectory}/.config/oh-my-zsh-custom";
      # Lazy-load nvm (node/npm are managed by nvm, not nix).
      initExtra = ''
        lazynvm() {
          unset -f nvm node npm
          export NVM_DIR=~/.nvm
          [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
          if [ -f "$NVM_DIR/bash_completion" ]; then
            [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
          fi
        }
        nvm() { lazynvm nvm "$@" }
        node() { lazynvm node "$@" }
        npm() { lazynvm npm "$@" }
      ''
      + cfg.zshExtra;
    };

    # Editors (from SETUP.md). The apps themselves come via casks.
    my.programs.vscode = {
      enable = true;
      settingsSource = ./darwin/vscode/settings.json;
    };
    my.programs.ideavim = {
      enable = true;
      source = ./darwin/ideavimrc;
    };

    # Vendored oh-my-zsh custom theme + plugin (no network/hash needed).
    home.file.".config/oh-my-zsh-custom/themes/pi.zsh-theme".source = ./darwin/zsh/pi.zsh-theme;
    home.file.".config/oh-my-zsh-custom/plugins/cmdtime/cmdtime.plugin.zsh".source =
      ./darwin/zsh/plugins/cmdtime/cmdtime.plugin.zsh;
  };
}
