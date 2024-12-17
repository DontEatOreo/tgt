{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.tgt-telegram;

  inherit (lib)
    mkIf
    mkOption
    types
    ;

  toTOML = (pkgs.formats.toml { }).generate;
  tgtLib = import ../lib.nix;
  inherit (tgtLib) mkAbsolutePath mkTgtPath;
in
{
  options.programs.tgt-telegram.loggerConfig = {
    level = mkOption {
      type = types.enum [
        "error"
        "warn"
        "info"
        "debug"
        "trace"
        "off"
      ];
      default = "info";
      description = "Logging level";
    };
    rotationFrequency = mkOption {
      type = types.enum [
        "minutely"
        "hourly"
        "daily"
        "never"
      ];
      default = "daily";
      description = "Log rotation frequency";
    };
    logDir = mkOption {
      type = types.str;
      default = ".local/share/tgt/logs";
      description = "Directory for log files (relative to home directory)";
    };
    logFile = mkOption {
      type = types.str;
      default = "tgt.log";
      description = "Name of the log file";
    };
    maxOldLogFiles = mkOption {
      type = types.int;
      default = 7;
      description = "Maximum number of old log files to keep";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.stringLength cfg.loggerConfig.logFile > 0;
        message = "programs.tgt-telegram: Log file name cannot be empty";
      }
      {
        assertion = cfg.loggerConfig.maxOldLogFiles >= 0;
        message = "programs.tgt-telegram: Maximum number of old log files must be non-negative";
      }
    ];
    home.file."${mkTgtPath "logger.toml"}".source = toTOML "logger" {
      log_dir = mkAbsolutePath cfg.loggerConfig.logDir config.home.homeDirectory;
      log_file = cfg.loggerConfig.logFile;
      rotation_frequency = cfg.loggerConfig.rotationFrequency;
      max_old_log_files = cfg.loggerConfig.maxOldLogFiles;
      log_level = cfg.loggerConfig.level;
    };
  };
}
