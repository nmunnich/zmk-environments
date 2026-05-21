# ZMK build toolchain definition
{ pkgs, lib, zephyrNix }:
let
  # ---------------------------------------------------------------------------
  # Zephyr SDK variants
  # ---------------------------------------------------------------------------
  sdkArm = zephyrNix.sdk-0_16.override {
    targets = ["arm-zephyr-eabi"];
  };
  sdkAll = zephyrNix.sdkFull-0_16;

  # ---------------------------------------------------------------------------
  # Python environments
  # ---------------------------------------------------------------------------
  zephyrPythonEnv = zephyrNix.pythonEnv;
  pythonEnv = zephyrPythonEnv.withPackages (ps: [
    ps.cmake
    ps.protobuf
    ps."grpcio-tools"
  ]);

  # ---------------------------------------------------------------------------
  # build & core tools
  # ---------------------------------------------------------------------------
  zmkBaseTools =
    [
      pkgs.bash
      pkgs.ccache
      pkgs.cmake
      pkgs.coreutils
      pkgs.dtc
      pkgs.file
      pkgs.gcc
      pkgs.gnumake
      pkgs.git
      pkgs.gperf
      pkgs.ninja
      pkgs.openssh
      pkgs.protobuf
    ]
    ++ lib.optionals (pkgs.stdenv.system == "x86_64-linux") [
      pkgs.gcc_multi
    ];

  zmkBuildTools = zmkBaseTools ++ [pythonEnv sdkArm];

  zmkBuildEnvWithSdk = sdkPkg: [
    "PYTHONPATH=${pythonEnv}/${pythonEnv.sitePackages}"
    "ZEPHYR_SDK_INSTALL_DIR=${sdkPkg}"
  ];

  zmkBuildShellHook = ''
  '';

  zmkBuildShellEnvWithSdk = sdkPkg: {
    PYTHONPATH = "${pythonEnv}/${pythonEnv.sitePackages}";
    ZEPHYR_SDK_INSTALL_DIR = "${sdkPkg}";
  };
in {
  inherit
    sdkArm
    sdkAll
    pythonEnv
    zmkBaseTools
    zmkBuildTools
    zmkBuildEnvWithSdk
    zmkBuildShellHook
    zmkBuildShellEnvWithSdk
    ;
}