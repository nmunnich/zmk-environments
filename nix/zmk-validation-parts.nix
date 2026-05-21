# ZMK validation image parts
#
# Minimal configuration for hardware metadata schema validation.
{ pkgs, lib, zmkBuildToolchain }:
let
  validationPythonEnv = zmkBuildToolchain.pythonEnv.withPackages (ps: [
    ps.remarshal
    ps.jsonschema
  ]);
in
{
  inherit validationPythonEnv;

  zmkValidationTools = [
    pkgs.git
    validationPythonEnv
  ];

  zmkValidationEnv = [
    "PYTHONPATH=${validationPythonEnv}/${validationPythonEnv.sitePackages}"
  ];
}
