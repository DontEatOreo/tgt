# Nix Quick Start

## Important: Credentials Configuration

Before starting, you'll need to configure your Telegram API credentials. There are two ways to do this:

Before doing anything else, you'll need to configure your Telegram API credentials. There are two ways to do this:

1. **Recommended: Using Environment Variables** (via `environmentFile`)
   - Most secure way
   - It keeps credentials out of the Nix store
   - It works with secrets management tools like [sops-nix](https://github.com/Mic92/sops-nix) or [agenix](https://github.com/ryantm/agenix)
2. **NOT Recommended: Direct Configuration**
   > [!WARNING]
   > Setting `telegramConfig.apiId` and `telegramConfig.apiHash` directly in your configuration is **STRONGLY DISCOURAGED**
   - Credentials WILL end up in the Nix store
   - **VERY** big likelihood you **WILL** accidentally commit your credentials

### Setting Up with sops-nix (Recommended Approach)

Configure your Home Manager module to use sops-nix for managing TGT credentials:

```nix
{
  programs.tgt-telegram = {
    enable = true;
    environmentFile = config.sops.secrets.tgt-credentials.path;
  };
}
```

For information on setting up sops-nix and managing secrets, see [sops-nix](https://github.com/Mic92/sops-nix).

### Direct Configuration (NOT Recommended)

> [!CAUTION]
> This method is NOT recommended as it stores credentials in the Nix store!
> Only really use this for testing purposes or if you fully understand the security implications.

```nix
{
  programs.tgt-telegram = {
    enable = true;
    telegramConfig = {
      apiId = "12345678";
      apiHash = "0123456789abcdef0123456789abcdef";
    };
  };
}
```

## Configuration

The home manager module already comes with the same sensible defaults that it provides by default, but you're free to customize any of its options, as shown below:

### Default Configuration

```nix
{
  programs.tgt-telegram = {
    enable = true;
    # All other options are optional (except for either environmentFile or telegramConfig.apiID and telegramConfig.apiHash)
  };
}
```

### Example: Debug Configuration

```nix
{
  programs.tgt-telegram = {
    enable = true;
    appConfig = {
      frameRate = 15.0;           # Slow FPS for easier debugging
      mouseSupport = true;        # Enable all inputs for testing
    };
    loggerConfig = {
      level = "trace";           # Maximum logging detail
      rotationFrequency = "minutely"; # Frequent rotations for testing
      maxOldLogFiles = 100;      # Keep more logs for analysis
      logDir = ".local/share/tgt/debug-logs";
    };
  };
}
```

### Keybinding Configuration

You can directly configure your keybinds via Nix like this:

```nix
{ tgt-telegram, ... }:
let
  inherit (tgt-telegram.lib) kb;
in {
  programs.tgt-telegram = {
    enable = true;
    keybindings = [
      (kb "[ctrl+n]" "next_chat" "Move to next chat")
      (kb "[ctrl+p]" "previous_chat" "Move to previous chat")
      (kb "[j]" "next_message" "Next message") 
      (kb "[k]" "previous_message" "Previous message")
      (kb "[g]" "last_message" "Jump to last message")
    ];
  };
}
```

### Theme Configuration

Just as you can configure your keybinds via Nix, you can do the same with the theme, like this:

```nix
{ tgt-telegram, ... }:
let
  inherit (tgt-telegram.lib) mkColor mkStyle;
in {
  programs.tgt-telegram = {
    enable = true;
    theme = {
      palette = {
        background = mkColor "1a1b26";
        foreground = mkColor "c0caf5";
        selection = mkColor "33467c";
      };
      styles = {
        timestamp = mkStyle "foreground" "background" { dim = true; };
        username = mkStyle "foreground" "background" { bold = true; };
      };
    };
  };
}
```

### Manual Attribute Sets

You can write your keybinds and themes manually *(as in writing the full attribute sets yourself)*, BUT it's advised to use the functions the library provides, as it takes much less code and the interface is more set in stone

```nix
{
  programs.tgt-telegram = {
    enable = true;
    keybindings = [
      {
        key = "[ctrl+n]";
        action = "next_chat";
        description = "Move to next chat";
      }
    ];
    theme = {
      palette = {
        background = { hex = "1a1b26"; };
        foreground = { hex = "c0caf5"; };
      };
      styles = {
        timestamp = {
          fg = "foreground";
          bg = "background";
          attributes = { dim = true; };
        };
      };
    };
  };
}
```

### Example: Full Configuration

Here's an example that has a small portion of all configuration options:

```nix
{ tgt-telegram, ... }:
let
  inherit (tgt-telegram.lib) kb mkColor mkStyle;
in {
  programs.tgt-telegram = {
    enable = true;
    
    # App configuration
    appConfig = {
      frameRate = 60.0;
      mouseSupport = true;
    };

    # Theme configuration
    theme = {
      colors = {
        background = mkColor "1a1b26";
        foreground = mkColor "c0caf5";
        selection = mkColor "33467c";
      };
      styles = {
        timestamp = mkStyle "foreground" "background" { dim = true; };
        username = mkStyle "foreground" "background" { bold = true; };
      };
    };

    keybindings = [
      # Window Management
      (kb "[alt+1]" "focus_chat_list" "Focus chat list")
      (kb "[alt+2]" "focus_chat" "Focus chat window") 
      (kb "[alt+3]" "focus_prompt" "Focus prompt")
      
      # Navigation
      (kb "[j]" "next_message" "Next message")
      (kb "[k]" "previous_message" "Previous message")
      (kb "[ctrl+d]" "page_down" "Page down")
      (kb "[ctrl+u]" "page_up" "Page up")
      
      # Actions
      (kb "[r]" "reply" "Reply to message")
      (kb "[e]" "edit" "Edit message")
      (kb "[y]" "copy" "Copy message")
      (kb "[d]" "delete" "Delete message")
    ];
  };
}
```

For a complete list of all available keybinding actions and theme options, etc, see the [Docs](../docs/configuration/README.md).
