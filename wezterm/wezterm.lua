local wezterm = require("wezterm")
local act = wezterm.action

local is_macos = wezterm.target_triple:find("apple")

local config = {
    font = wezterm.font_with_fallback({
        "JetBrainsMono Nerd Font",
    }),
    font_size = 12,
    color_scheme = "OneDark (base16)",
    -- Flatten just the background to pure black for OLED, same approach as
    -- BreezeDarkOled.colors — everything else stays OneDark's stock palette.
    colors = {
        background = "#000000",
    },

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

    initial_rows = 32,
    initial_cols = 120,

    -- Fully opaque so the OLED-black background renders as true black
    -- regardless of what's behind the window (macos_window_background_blur
    -- has no effect at opacity 1.0, so it's dropped too).
    window_background_opacity = 1.0,

    enable_scroll_bar = false,
    native_macos_fullscreen_mode = true,

    default_prog = { "zsh", "-l" },

    adjust_window_size_when_changing_font_size = false,

    exit_behavior = "Close",
    window_close_confirmation = "NeverPrompt",
}

-- Pane multiplexing: identical on both platforms (CTRL+SHIFT so it never
-- depends on keyd's Super layer on Linux or Cmd on macOS). Vim-style h/j/k/l
-- for navigation; add ALT to split in that direction instead.
local pane_keys = {
    { key = "h", mods = "CTRL|SHIFT",      action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "CTRL|SHIFT",      action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "CTRL|SHIFT",      action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "CTRL|SHIFT",      action = act.ActivatePaneDirection("Right") },

    { key = "h", mods = "CTRL|SHIFT|ALT",  action = act.SplitPane({ direction = "Left" }) },
    { key = "j", mods = "CTRL|SHIFT|ALT",  action = act.SplitPane({ direction = "Down" }) },
    { key = "k", mods = "CTRL|SHIFT|ALT",  action = act.SplitPane({ direction = "Up" }) },
    { key = "l", mods = "CTRL|SHIFT|ALT",  action = act.SplitPane({ direction = "Right" }) },

    { key = "z", mods = "CTRL|SHIFT",      action = act.TogglePaneZoomState },
    { key = "w", mods = "CTRL|SHIFT",      action = act.CloseCurrentPane({ confirm = false }) },
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
else
    config.keys = {
        -- Super+C arrives as Ctrl+C via keyd. Copy if text is selected, SIGINT otherwise.
        {
            key = "c",
            mods = "CTRL",
            action = wezterm.action_callback(function(window, pane)
                local sel = window:get_selection_text_for_pane(pane)
                if sel and #sel > 0 then
                    window:perform_action(act.CopyTo("Clipboard"), pane)
                else
                    window:perform_action(act.SendKey({ key = "c", mods = "CTRL" }), pane)
                end
            end),
        },
    }
end

for _, k in ipairs(pane_keys) do
    table.insert(config.keys, k)
end

return config
