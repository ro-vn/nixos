# Host builders shared by every machine. mkDarwin / mkNixos assemble a full
# system by layering: common config -> platform config -> host config ->
# home-manager. This is the flake-parts-native equivalent of the `mkHost`
# helpers in the reference repos.
{ inputs, self }:
let
  inherit (inputs)
    nixpkgs
    nixpkgs-unstable
    home-manager
    nix-darwin
    disko
    ;

  # Overlays applied to every host. `pkgs.unstable.<name>` pulls a package from
  # nixpkgs-unstable; ../overlays holds custom package definitions.
  overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    })
    (import ../overlays)
  ];

  mkSpecialArgs =
    { username, hostname }:
    {
      inherit inputs self username hostname;
    };

  # Shared home-manager wiring (used by both platforms).
  hmModule =
    { username, hostname }:
    homeModule:
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-bak";
      home-manager.extraSpecialArgs = mkSpecialArgs { inherit username hostname; };
      home-manager.users.${username} = import homeModule;
    };
in
{
  mkDarwin =
    {
      hostname,
      username,
      system ? "aarch64-darwin",
    }:
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = mkSpecialArgs { inherit username hostname; };
      modules = [
        { nixpkgs.overlays = overlays; }
        ../hosts/common/shared.nix
        ../hosts/common/darwin.nix
        ../hosts/${hostname}
        home-manager.darwinModules.home-manager
        (hmModule { inherit username hostname; } ../home/macbook.nix)
      ];
    };

  mkNixos =
    {
      hostname,
      username,
      system ? "x86_64-linux",
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = mkSpecialArgs { inherit username hostname; };
      modules = [
        { nixpkgs.overlays = overlays; }
        disko.nixosModules.disko
        ../hosts/common/shared.nix
        ../hosts/common/nixos.nix
        ../hosts/${hostname}
        home-manager.nixosModules.home-manager
        (hmModule { inherit username hostname; } ../home/n100.nix)
      ];
    };
}
