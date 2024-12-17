{
  lib,
  pkgs,
  config,
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
  inherit (tgtLib) mkColor mkStyle mkTgtPath;

  colorType = types.strMatching "#[0-9a-fA-F]{6}";

  themeType = types.submodule {
    options = {
      palette = mkOption {
        type = types.attrsOf colorType;
        default = defaultTheme.palette;
        description = "Color palette";
      };
      common = mkOption {
        type = types.attrs;
        default = defaultTheme.common;
        description = "Common styling";
      };
      chat_list = mkOption {
        type = types.attrs;
        default = defaultTheme.chat_list;
        description = "Chat list styling";
      };
      chat = mkOption {
        type = types.attrs;
        default = defaultTheme.chat;
        description = "Chat styling";
      };
      prompt = mkOption {
        type = types.attrs;
        default = defaultTheme.prompt;
        description = "Prompt styling";
      };
      reply_message = mkOption {
        type = types.attrs;
        default = defaultTheme.reply_message;
        description = "Reply message styling";
      };
      status_bar = mkOption {
        type = types.attrs;
        default = defaultTheme.status_bar;
        description = "Status bar styling";
      };
      title_bar = mkOption {
        type = types.attrs;
        default = defaultTheme.title_bar;
        description = "Title bar styling";
      };
    };
  };

  defaultTheme = {
    palette = {
      black = mkColor "000000";
      white = mkColor "ffffff";
      background = mkColor "000000";
      primary = mkColor "00548e";
      primary_variant = mkColor "0073b0";
      primary_light = mkColor "94dbf7";
      secondary = mkColor "ca3f04";
      secondary_variant = mkColor "e06819";
      secondary_light = mkColor "fcac77";
      ternary = mkColor "696969";
      ternary_variant = mkColor "808080";
      ternary_light = mkColor "6e7e85";
      surface = mkColor "141414";
      on_surface = mkColor "dcdcdc";
      error = mkColor "D50000";
      on_error = mkColor "FFCDD2";
    };
    common = {
      border_component_focused = mkStyle "secondary" "background" { };
      item_selected = mkStyle "" "surface" { bold = true; };
      timestamp = mkStyle "ternary_light" "background" { };
    };
    chat_list = {
      self = mkStyle "primary" "background" { };
      item_selected = mkStyle "" "primary" { };
      item_chat_name = mkStyle "primary_light" "background" { bold = true; };
      item_message_content = mkStyle "secondary_light" "background" { italic = true; };
      item_unread_counter = mkStyle "secondary" "background" { bold = true; };
    };
    chat = {
      self = mkStyle "primary" "background" { };
      chat_name = mkStyle "secondary" "background" { bold = true; };
      message_myself_name = mkStyle "primary_light" "background" { bold = true; };
      message_myself_content = mkStyle "primary_variant" "background" { };
      message_other_name = mkStyle "secondary_light" "background" { bold = true; };
      message_other_content = mkStyle "secondary_variant" "background" { };
      message_reply_text = mkStyle "ternary" "background" { };
      message_reply_name = mkStyle "secondary_light" "background" { bold = true; };
      message_reply_content = mkStyle "secondary_variant" "background" { };
    };
    prompt = {
      self = mkStyle "primary" "background" { };
      message_text = mkStyle "primary_light" "background" { };
      message_text_selected = mkStyle "secondary_light" "ternary" { italic = true; };
      message_preview_text = mkStyle "ternary" "background" { };
    };
    reply_message = {
      self = mkStyle "secondary_light" "background" { };
      message_text = mkStyle "secondary_variant" "background" { };
    };
    status_bar = {
      self = mkStyle "on_surface" "surface" { };
      size_info_text = mkStyle "primary_light" "surface" { };
      size_info_numbers = mkStyle "secondary_light" "surface" { italic = true; };
      press_key_text = mkStyle "primary_light" "surface" { };
      press_key_key = mkStyle "secondary_light" "surface" { italic = true; };
      message_quit_text = mkStyle "primary_light" "surface" { };
      message_quit_key = mkStyle "secondary_light" "surface" { italic = true; };
      open_chat_text = mkStyle "primary_light" "surface" { };
      open_chat_name = mkStyle "secondary_light" "surface" { italic = true; };
    };
    title_bar = {
      self = mkStyle "on_surface" "surface" { };
      title1 = mkStyle "primary_light" "surface" {
        bold = true;
        underline = true;
        italic = true;
      };
      title2 = mkStyle "secondary_light" "surface" {
        bold = true;
        underline = true;
        italic = true;
      };
      title3 = mkStyle "ternary_light" "surface" {
        bold = true;
        underline = true;
      };
    };
  };
in
{
  options.programs.tgt-telegram.theme = mkOption {
    type = types.nullOr themeType;
    default = defaultTheme;
    description = "Theme configuration";
  };

  config = mkIf cfg.enable {
    home.file."${mkTgtPath "theme.toml"}".source = mkIf (cfg.theme != null) (toTOML "theme" cfg.theme);
  };
}
