# Custom library, merged into nixpkgs.lib via `lib.extend` in flake.nix.
# Everything returned here becomes `lib.<name>` throughout the flake and inside
# every module (the extended lib is passed through specialArgs). Add new helpers
# here; keep machine wiring in mkDarwin / mkHome.
{ inputs, self, lib }:
let
  inherit (inputs)
    nixpkgs
    nixpkgs-unstable
    home-manager
    nix-darwin
    ;

  systems = [
    "aarch64-darwin" # macmini
    "aarch64-linux" # rpi5
  ];

  # Overlays applied to every host and dev shell. `pkgs.unstable.<name>` pulls
  # from nixpkgs-unstable; ../overlays holds custom package definitions.
  overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    })
    (import ../overlays)
  ];

  # Arguments handed to every system + home-manager module. Threading the
  # extended `lib` here is what makes custom helpers available in modules.
  mkSpecialArgs =
    { username, hostname }:
    {
      inherit
        inputs
        self
        lib
        username
        hostname
        ;
    };

  # The user's home config: the auto-imported module tree plus the host's home
  # file (which flips toggles). Shared by both the nix-darwin system module and
  # the standalone builder.
  homeModules = hostname: [
    ../modules/home-manager
    ../homes/${hostname}.nix
  ];

  # Instantiate nixpkgs for a system with our overlays applied.
  mkPkgs =
    system:
    import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

  # home-manager as a nix-darwin system module (macmini). username and
  # homeDirectory are derived from the system user, so we don't set them.
  hmSystemModule =
    { username, hostname }:
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-bak";
      home-manager.extraSpecialArgs = mkSpecialArgs { inherit username hostname; };
      home-manager.users.${username}.imports = homeModules hostname;
    };
in
{
  # Map a function over every supported system, given an instantiated `pkgs`.
  forAllSystems = f: lib.genAttrs systems (system: f (mkPkgs system));

  # A Mac: nix-darwin manages the system layer, home-manager rides along as a
  # system module. Produces `darwinConfigurations.<hostname>`.
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
        ../modules/darwin
        ../hosts/${hostname}
        home-manager.darwinModules.home-manager
        (hmSystemModule { inherit username hostname; })
      ];
    };

  # A machine we don't own the OS of (rpi5 on Raspberry Pi OS): Nix is just a
  # package manager and home-manager is the config manager. No system layer, so
  # there is no hosts/<hostname>/ — the home file is the whole config, and
  # username/homeDirectory must be set explicitly. Produces
  # `homeConfigurations.<hostname>`, applied with `home-manager switch`.
  mkHome =
    {
      hostname,
      username,
      system ? "aarch64-linux",
      homeDirectory ? "/home/${username}",
    }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs = mkSpecialArgs { inherit username hostname; };
      modules = homeModules hostname ++ [
        { home = { inherit username homeDirectory; }; }
      ];
    };
}
