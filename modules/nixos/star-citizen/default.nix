flake-self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  flake-packages = flake-self.packages.${pkgs.system};
  cfg = config.nix-citizen.starCitizen;
  smartPackage =
    pname:
    if (builtins.hasAttr pname pkgs) then
      pkgs.${pname}
    else
      builtins.trace
        "Warning: pkgs does not include ${pname} (missing overlay?) using nix-citizen's package"
        flake-packages.${pname};
in
with lib;
{
  options.nix-citizen.starCitizen = {
    enable = mkEnableOption "Enable star-citizen";
    package = mkOption {
      description = "Package to use for star-citizen";
      type = types.package;
      default = smartPackage "star-citizen-umu";
      apply =
        star-citizen:
        star-citizen.override (_old: {
          preCommands = ''
            ${cfg.preCommands}
            ${if cfg.helperScript.enable then "${cfg.helperScript.package}/bin/star-citizen-helper" else ""}
          '';
          inherit (cfg) postCommands location;
        });
    };
    location = mkOption {
      default = "$HOME/Games/star-citizen";
      type = types.str;
      description = "Path to install star-citizen";
    };
    preCommands = mkOption {
      default = "";
      type = types.str;
      description = "Additional commands to be run before star-citizen is run";
      example = ''
        export DXVK_HUD=compiler
        export MANGO_HUD=1
      '';
    };
    postCommands = mkOption {
      default = "";
      type = types.str;
      description = "Additional commands to be run after star-citizen is run";
    };
    helperScript = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Star-citizen helper script to detect if the game has an update or not & clear cache";
      };
      package = mkOption {
        description = "Package to use for star-citizen-helper";
        type = types.package;
        default = smartPackage "star-citizen-helper";
      };
    };
    setLimits = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Configures your system to meet some of the requirements to run star-citizen
        Set `vm.max_map_count` default to `16777216` (sysctl(8))
        Set `fs.file-max` default to `524288` (sysctl(8))

        Also sets `security.pam.loginLimits` to increase hard (limits.conf(5))

        Changes outlined in  https://github.com/starcitizen-lug/knowledge-base/wiki/Manual-Installation#prerequisites
      '';
    };
  };
  config = mkIf cfg.enable {
    assertions = [ ];
    boot.kernel.sysctl = mkIf cfg.setLimits {
      "vm.max_map_count" = mkOverride 999 16777216;
      "fs.file-max" = mkOverride 999 524288;
    };
    security.pam = mkIf cfg.setLimits {
      loginLimits = [
        {
          domain = "*";
          type = "soft";
          item = "nofile";
          value = "16777216";
        }
      ];
    };
    environment.systemPackages = [ cfg.package ];
  };
}
