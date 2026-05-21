# ZMK local development shell addons
#
# Enhances the build environment passed in (expected to be 
# from zmk-build-toolchain.nix) with additional packages and environment
# variables for local development, debugging, and testing.
{ pkgs, lib, zmkBuildToolchain, zmkValidationParts }:
{
  zmkDevTools =
    zmkBuildToolchain.zmkBaseTools
    ++ [
      zmkValidationParts.validationPythonEnv
      zmkBuildToolchain.sdkAll
      pkgs.SDL2
      pkgs.cacert
      pkgs.clang-tools
      pkgs.curl
      pkgs.docker
      pkgs.gdb
      pkgs.gnupg
      pkgs.less
      pkgs.nano
      pkgs.nodejs_20
      pkgs.python3
      pkgs.python3Packages.pip
      pkgs.python3Packages.setuptools
      pkgs.python3Packages.wheel
      pkgs.socat
      pkgs.tio
      pkgs.wget
      pkgs.xz
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Matches locale setup in the Ubuntu-based Docker images.
      pkgs.glibcLocales
    ];

  zmkDevEnv = {
    PYTHONPATH = "${zmkValidationParts.validationPythonEnv}/${zmkValidationParts.validationPythonEnv.sitePackages}";
    ZEPHYR_SDK_INSTALL_DIR = "${zmkBuildToolchain.sdkAll}";
  };

  zmkDevHook = ''
  '';
}