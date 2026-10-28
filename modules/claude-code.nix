{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  claude-code = inputs.agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
in {
  options.agents.claude-code.enable = lib.mkEnableOption "claude-code agent";

  config = lib.mkIf config.agents.claude-code.enable {
    environment.systemPackages = [
      claude-code
      pkgs.sox
    ];

    programs.zsh.shellAliases = {
      c = "claude";
    };
  };
}
