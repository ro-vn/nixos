{
  description = "nix-darwin + home-manager configuration for local machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      # Extend nixpkgs.lib with our own helpers (mkDarwin/mkHome/forAllSystems).
      # The extended lib is also threaded into every module via specialArgs, so
      # `lib.<helper>` is available repo-wide. This is the "custom-lib" style of
      # the reference repos, in place of flake-parts.
      lib = nixpkgs.lib.extend (
        final: _prev: import ./lib { inherit inputs self; lib = final; }
      );
    in
    {
      # Macs — nix-darwin owns the system, home-manager the user. Both share
      # modules/darwin/ + the profiles/darwin home profile; the differences live
      # in hosts/<name>/default.nix and homes/<name>.nix.
      darwinConfigurations.macmini = lib.mkDarwin {
        hostname = "macmini";
        username = "rnvo";
      };

      darwinConfigurations.macbook = lib.mkDarwin {
        hostname = "macbook";
        username = "rnvo";
        # system = "x86_64-darwin"; # uncomment if this MacBook is Intel
      };

      # Raspberry Pi 5 — stock Raspberry Pi OS; Nix is only a package manager
      # and home-manager the config manager. Applied with `home-manager switch`.
      homeConfigurations.rpi5 = lib.mkHome {
        hostname = "rpi5";
        username = "rnvo";
      };

      # Dev shell: `nix develop` (or via direnv).
      devShells = lib.forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            just
            nixfmt-rfc-style
            nil # nix language server
            git
          ];
        };
      });

      # `nix fmt` — nixfmt-tree recurses the whole repo.
      formatter = lib.forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
