use serde::Deserialize;

#[derive(Clone, Debug, Deserialize)]
/// The command keymap configuration.
pub struct KeymapEntry {
    /// The key combination.
    /// It must be a valid key combination.
    pub keys: Vec<String>, // Event
    /// The command to execute.
    /// It must be a valid command.
    pub command: String, // Action
    /// The description of the command.
    pub description: Option<String>,
}

#[derive(Clone, Debug, Deserialize)]
/// The keymap configuration.
pub struct KeymapMode {
    #[serde(default)]
    /// The keymap entries.
    pub keymap: Vec<KeymapEntry>,
}

#[derive(Clone, Debug, Deserialize)]
/// The raw keymap configuration.
pub struct KeymapRaw {
    /// The keymap for the core window mode, they are used in all components.
    pub core_window: Option<KeymapMode>,
    /// The keymap for the chat list mode.
    pub chat_list: Option<KeymapMode>,
    /// The keymap for the chat mode.
    pub chat: Option<KeymapMode>,
    /// The keymap for the chat edit mode.
    pub prompt: Option<KeymapMode>,
}
