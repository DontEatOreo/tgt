{
  pkgs,
  lib,
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
  inherit (tgtLib) kb mkTgtPath;

  defaultKeybindings = [
    # Core window bindings
    (kb "[q]" "try_quit" "Quit the application")
    (kb "[ctrl+c]" "try_quit" "Quit the application")
    (kb "[alt+1]" "focus_chat_list" "Focus the chat list")
    (kb "[alt+left]" "focus_chat_list" "Focus the chat list")
    (kb "[alt+2]" "focus_chat" "Focus the chat")
    (kb "[alt+right]" "focus_chat" "Focus the chat")
    (kb "[alt+3]" "focus_prompt" "Focus the prompt")
    (kb "[alt+down]" "focus_prompt" "Focus the prompt")
    (kb "[esc]" "unfocus_component" "Unfocus the component")
    (kb "[alt+up]" "unfocus_component" "Unfocus the component")
    (kb "[alt+n]" "toggle_chat_list" "Toggle chat_list visibility")
    (kb "[alt+l]" "increase_chat_list_size" "Increase chat list size")
    (kb "[alt+h]" "decrease_chat_list_size" "Decrease chat list size")
    (kb "[alt+k]" "increase_prompt_size" "Increase prompt size")
    (kb "[alt+j]" "decrease_prompt_size" "Decrease prompt size")

    # Chat list bindings
    (kb "[down]" "chat_list_next" "Select the next chat")
    (kb "[up]" "chat_list_previous" "Select the previous chat")
    (kb "[left]" "chat_list_unselect" "Unselect the current chat")
    (kb "[right]" "chat_list_open" "Open the selected chat")
    (kb "[enter]" "chat_list_open" "Open the selected chat")

    # Chat window bindings
    (kb "[down]" "chat_window_next" "Select the next message")
    (kb "[up]" "chat_window_previous" "Select the previous message")
    (kb "[left]" "chat_window_unselect" "Unselect the current message")
    (kb "[d]" "chat_window_delete_for_everyone" "Delete the selected message for all users")
    (kb "[D]" "chat_window_delete_for_me" "Delete the selected message for 'me'")
    (kb "[y]" "chat_window_copy" "Copy the selected message")
    (kb "[ctrl+c]" "chat_window_copy" "Copy the selected message")
    (kb "[e]" "chat_window_edit" "Edit the selected message")
    (kb "[r]" "chat_window_reply" "Reply to the selected message")
  ];

  mkKeybind =
    {
      key,
      action,
      description ? "",
    }:
    {
      keys = [ (pkgs.lib.removePrefix "[" (pkgs.lib.removeSuffix "]" key)) ];
      command = action;
      inherit description;
    };

  groupKeybindings =
    keybindings:
    let
      sortKeybindings = list: pkgs.lib.sort (a: b: a.action < b.action) list;
      isChatListCommand = binding: pkgs.lib.hasPrefix "chat_list_" binding.action;
      isChatWindowCommand = binding: pkgs.lib.hasPrefix "chat_window_" binding.action;
      isPromptCommand = binding: pkgs.lib.hasPrefix "prompt_" binding.action;

      chatListBindings = sortKeybindings (builtins.filter isChatListCommand keybindings);
      chatWindowBindings = sortKeybindings (builtins.filter isChatWindowCommand keybindings);
      promptBindings = sortKeybindings (builtins.filter isPromptCommand keybindings);
      coreBindings = sortKeybindings (
        builtins.filter (
          binding: !(isChatListCommand binding || isChatWindowCommand binding || isPromptCommand binding)
        ) keybindings
      );
    in
    {
      core_window.keymap = map mkKeybind coreBindings;
      chat_list.keymap = map mkKeybind chatListBindings;
      chat.keymap = map mkKeybind chatWindowBindings;
      prompt.keymap = map mkKeybind promptBindings;
    };

  keybindingsToAttrs = keybindings: groupKeybindings keybindings;
in
{
  options.programs.tgt-telegram.keybindings = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          key = mkOption {
            type = types.str;
            example = "[ctrl+n]";
            description = "Key combination in brackets";
          };
          action = mkOption {
            type = types.str;
            example = "next_chat";
            description = "Action to perform";
          };
          description = mkOption {
            type = types.str;
            example = "Move to next chat";
            description = "Description of what the keybinding does";
          };
        };
      }
    );
    default = defaultKeybindings;
    description = "List of keybindings";
  };

  config = mkIf cfg.enable {
    home.file = {
      "${mkTgtPath "keymap.toml"}".source = mkIf (cfg.keybindings != [ ]) (
        toTOML "" (keybindingsToAttrs cfg.keybindings)
      );
    };
  };
}
