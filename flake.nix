{
  description = "ZMK build, test, and development shell environments";

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
    # Building the Docker images requires a Linux host.
    dockerSystems = ["x86_64-linux" "aarch64-linux"];
    forDockerSystems = nixpkgs.lib.genAttrs dockerSystems;

    shellSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forShellSystems = nixpkgs.lib.genAttrs shellSystems;

    mkZMKBuildToolchain = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      zephyrNix = zephyr-nix.packages.${system};
    in
      import ./nix/zmk-build-toolchain.nix {inherit pkgs lib zephyrNix;};

    mkImageBuilder = system:
      import ./nix/image-builder.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      };
  in {
    # -------------------------------------------------------------------------
    # Docker images
    # -------------------------------------------------------------------------
    packages = forDockerSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      zmkBuildToolchain = mkZMKBuildToolchain system;
      imageBuilder = mkImageBuilder system;
      zmkValidationParts = import ./nix/zmk-validation-parts.nix {inherit pkgs lib zmkBuildToolchain;};
    in {
      zmk-build-arm-image = imageBuilder {
        name = "zmk-build-arm";
        paths = zmkBuildToolchain.zmkBuildTools;
        env = zmkBuildToolchain.zmkBuildEnvWithSdk zmkBuildToolchain.sdkArm;
      };

      zmk-validation-image = imageBuilder {
        name = "zmk-validation";
        paths = zmkValidationParts.zmkValidationTools;
        env = zmkValidationParts.zmkValidationEnv;
      };
    });

    # -------------------------------------------------------------------------
    # Development and build shells
    # -------------------------------------------------------------------------
    devShells = forShellSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      zmkBuildToolchain = mkZMKBuildToolchain system;
      zmkValidationParts = import ./nix/zmk-validation-parts.nix {inherit pkgs lib zmkBuildToolchain;};
      zmkDevShellParts = import ./nix/zmk-dev-shell-parts.nix {inherit pkgs lib zmkBuildToolchain zmkValidationParts;};
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
