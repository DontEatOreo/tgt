{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.programs.tgt-telegram;
  toTOML = (pkgs.formats.toml { }).generate;
  tgtLib = import ../lib.nix;
  inherit (tgtLib) mkAbsolutePath mkTgtPath;
in
{
  imports = [
    ./keybinds.nix
    ./logger.nix
    ./theme.nix
  ];

  options.programs.tgt-telegram = {
    enable = mkEnableOption "tgt - TUI Telegram client";
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../tgt.nix { };
      description = "The tgt package to use.";
    };

    telegramConfig = {
      databaseDir = mkOption {
        type = types.str;
        default = ".local/share/tgt/data/tg";
        description = "Directory for the persistent database (relative to home directory)";
      };
      useFileDatabase = mkOption {
        type = types.bool;
        default = true;
        description = "Keep information about downloaded and uploaded files between application restarts";
      };
      useChatInfoDatabase = mkOption {
        type = types.bool;
        default = true;
        description = "Keep cache of users, basic groups, supergroups, channels and secret chats between restarts";
      };
      useMessageDatabase = mkOption {
        type = types.bool;
        default = true;
        description = "Keep cache of chats and messages between restarts";
      };
      systemLanguageCode = mkOption {
        type = types.str;
        default = "en";
        description = "IETF language tag of the user's operating system language";
      };
      deviceModel = mkOption {
        type = types.str;
        default = "Desktop";
        description = "Model of the device the application is being run on";
      };
      verbosityLevel = mkOption {
        type = types.int;
        default = 2;
        description = ''
          Verbosity level for logging. Values:
          0 = fatal errors
          1 = errors
          2 = warnings and debug warnings
          3 = informational
          4 = debug
          5 = verbose debug
          >5 up to 1023 = even more logging
        '';
      };
      logPath = mkOption {
        type = types.str;
        default = ".local/share/tgt/data/tdlib_rs/tdlib_rs.log";
        description = "Path to the file where the internal TDLib log will be written";
      };
      redirectStderr = mkOption {
        type = types.bool;
        default = false;
        description = "Additionally redirect stderr to the log file (ignored on Windows)";
      };
    };

    appConfig = {
      mouseSupport = mkOption {
        type = types.bool;
        default = true;
        description = "Enable mouse support";
      };
      frameRate = mkOption {
        type = types.float;
        default = 60.0;
        description = "Frame rate in FPS";
      };
      showStatusBar = mkOption {
        type = types.bool;
        default = true;
        description = "Show status bar";
      };
      showTitleBar = mkOption {
        type = types.bool;
        default = true;
        description = "Show title bar";
      };
      pasteSupport = mkOption {
        type = types.bool;
        default = true;
        description = "Enable paste support";
      };
      themeEnable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable theme support";
      };
      themeFilename = mkOption {
        type = types.str;
        default = "theme.toml";
        description = "Theme configuration filename";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      file = {
        # "${mkTgtPath "telegram.toml"}".source = toTOML "telegram" {
        #   database_dir = mkAbsolutePath cfg.telegramConfig.databaseDir;
        #   use_file_database = cfg.telegramConfig.useFileDatabase;
        #   use_chat_info_database = cfg.telegramConfig.useChatInfoDatabase;
        #   use_message_database = cfg.telegramConfig.useMessageDatabase;
        #   system_language_code = cfg.telegramConfig.systemLanguageCode;
        #   device_model = cfg.telegramConfig.deviceModel;
        #   verbosity_level = cfg.telegramConfig.verbosityLevel;
        #   log_path = mkAbsolutePath cfg.telegramConfig.logPath;
        #   redirect_stderr = cfg.telegramConfig.redirectStderr;
        # };

        "${mkTgtPath "app.toml"}".source = toTOML "app" {
          inherit (cfg.appConfig)
            mouseSupport
            pasteSupport
            frameRate
            showStatusBar
            showTitleBar
            themeEnable
            themeFilename
            ;
          take_api_id_from_telegram_config = true;
          take_api_hash_from_telegram_config = true;
        };
      };
    };

    assertions = [
      {
        assertion = builtins.stringLength (toString cfg.telegramConfig.databaseDir) > 0;
        message = "programs.tgt-telegram: Database directory path cannot be empty";
      }
      {
        assertion = cfg.appConfig.frameRate > 0.0;
        message = "programs.tgt-telegram: Frame rate must be positive";
      }
      {
        assertion = builtins.stringLength cfg.loggerConfig.logFile > 0;
        message = "programs.tgt-telegram: Log file name cannot be empty";
      }
      {
        assertion = builtins.stringLength cfg.appConfig.themeFilename > 0;
        message = "programs.tgt-telegram: Theme file name cannot be empty";
      }
      {
        assertion = cfg.loggerConfig.maxOldLogFiles >= 0;
        message = "programs.tgt-telegram: Maximum number of old log files must be non-negative";
      }
      {
        assertion = cfg.telegramConfig.verbosityLevel >= 0 && cfg.telegramConfig.verbosityLevel <= 1023;
        message = "programs.tgt-telegram: Verbosity level must be between 0 and 1023";
      }
    ];
  };
}
