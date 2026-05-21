{ pkgs }:
{
  name,
  paths,
  env,
  tag ? "latest",
  workingDir ? "/workspaces/zmk",
}:
pkgs.dockerTools.buildLayeredImage {
  inherit name tag;

  contents = [
    (pkgs.buildEnv {
      name = "${name}-env";
      inherit paths;
      pathsToLink = ["/bin" "/lib" "/share"];
    })
  ];

  config = {
    Cmd = ["/bin/bash"];
    Env = env;
    WorkingDir = workingDir;
  };
}