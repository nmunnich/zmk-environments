{
  description = "ZMK build and development shell environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    zephyr.url = "github:zmkfirmware/zephyr/v4.1.0+zmk-fixes";
    zephyr.flake = false;

    zephyr-nix.url = "github:nix-community/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    zephyr-nix,
    ...
  }: let
    shellSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forShellSystems = nixpkgs.lib.genAttrs shellSystems;

    mkZMKBuildToolchain = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      zephyrNix = zephyr-nix.packages.${system};
    in
      import ./nix/zmk-build-toolchain.nix {inherit pkgs lib zephyrNix;};
  in {
    # -------------------------------------------------------------------------
    # Build and development shells
    # -------------------------------------------------------------------------
    devShells = forShellSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      zmkBuildToolchain = mkZMKBuildToolchain system;
      zmkDevShellParts = import ./nix/zmk-dev-shell-parts.nix {inherit pkgs lib zmkBuildToolchain;};
    in {
      build = pkgs.mkShellNoCC {
        packages = zmkBuildToolchain.zmkBuildTools;
        env = zmkBuildToolchain.zmkBuildShellEnvWithSdk zmkBuildToolchain.sdkArm;
        shellHook = zmkBuildToolchain.zmkBuildShellHook;
      };
      dev = pkgs.mkShellNoCC {
        packages = zmkDevShellParts.zmkDevTools;
        env = zmkDevShellParts.zmkDevEnv;
        shellHook = zmkDevShellParts.zmkDevHook;
      };
    });
  };
}
