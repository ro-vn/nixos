# Homebrew, managed declaratively by nix-darwin.
#
# GUI apps (casks) and macOS-integration / service formulae stay in Homebrew
# because they are awkward or impossible to run from nixpkgs on darwin. Portable
# CLI tools are being migrated to home-manager (see modules/home-manager) over
# time.
#
# The lists below are the *shared* baseline every Mac gets. Per-machine additions
# go in hosts/<host>/default.nix via `my.darwin.homebrew.{taps,brews,casks}`,
# which are concatenated onto these.
#
# cleanup = "none" means nix-darwin will NOT uninstall anything that is present
# but unlisted — safe while migrating. Switch to "uninstall" once the lists are
# authoritative.
{ config, lib, ... }:
let
  cfg = config.my.darwin.homebrew;

  extraList =
    description:
    lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      inherit description;
    };
in
{
  options.my.darwin.homebrew = {
    enable = lib.mkEnableOption "declarative Homebrew with the shared Mac baseline";
    taps = extraList "Machine-specific taps, appended to the shared list.";
    brews = extraList "Machine-specific formulae, appended to the shared list.";
    casks = extraList "Machine-specific casks, appended to the shared list.";
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;

      onActivation = {
        autoUpdate = false;
        upgrade = false;
        cleanup = "none";
      };

      taps = [
        "jakehilborn/jakehilborn" # displayplacer
        "mickeyl/formulae" # mole
      ]
      ++ cfg.taps;

      brews = [
        # macOS-integration CLIs (better via brew than nixpkgs on darwin)
        "blueutil"
        "displayplacer"
        "mole"

        # Toolchains / build tools
        "autojump"
        "deno"
        "ffmpeg"
        "flyctl"
        "gh"
        "gnupg"
        "go"
        "go-task"
        "golang-migrate"
        "gradle"
        "gradle@6"
        "guile"
        "htop"
        "hugo"
        "pipx"
        "platformio"
        "tree"
        "wget"
        "yarn"
      ]
      ++ cfg.brews;

      casks = [
        "bluetility"
        "clipy"
        "iterm2"
        "kekaexternalhelper"
        "openkey"
        "raycast"
        "rectangle"
        "shottr"
        "stats"
        "bitwarden"
        "visual-studio-code"
        "podman-desktop" # container tool (chosen over Docker/Rancher Desktop)
        # "intellij-idea"  # skipped for now
      ]
      ++ cfg.casks;
    };
  };
}
