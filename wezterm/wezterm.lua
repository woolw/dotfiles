local wezterm = require("wezterm")
local act = wezterm.action

local target_shell
local is_windows = wezterm.target_triple:find("windows")
local is_macos = wezterm.target_triple:find("apple")

if is_windows then
    target_shell = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "-i" }
else
    target_shell = { "zsh", "-l" }
end

local config = {
    font = wezterm.font_with_fallback({
        "JetBrainsMono Nerd Font",
    }),
    font_size = 12,
    color_scheme = "OneDark (base16)",

    enable_tab_bar = false,
    use_fancy_tab_bar = false,
    window_decorations = "TITLE | RESIZE",
    hide_mouse_cursor_when_typing = true,
    hide_tab_bar_if_only_one_tab = true,

    window_padding = {
        left = 6,
        right = 6,
        top = 4,
        bottom = 4,
    },

    enable_wayland = false,

    initial_rows = 32,
    initial_cols = 120,

    window_background_opacity = 0.87,
    macos_window_background_blur = 20,

    enable_scroll_bar = false,
    native_macos_fullscreen_mode = true,

    default_prog = target_shell,

    adjust_window_size_when_changing_font_size = false,

    exit_behavior = "Close",
    window_close_confirmation = "NeverPrompt",
}

if is_macos then
    -- Treat Option as Meta (send escape sequences) instead of composing accented chars
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false

    config.keys = {
        -- Option+Left/Right: word navigation
        { key = "LeftArrow",  mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
        { key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
        -- Option+Backspace: delete word
        { key = "Backspace",  mods = "OPT", action = act.SendKey({ key = "w", mods = "CTRL" }) },
    }
end

return config
