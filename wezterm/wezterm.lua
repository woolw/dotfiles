local wezterm = require("wezterm")

local target_shell
local is_windows = wezterm.target_triple:find("windows")

if is_windows then
  target_shell = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "-i" }
else
  target_shell = { "/usr/bin/fish", "-l" }
end

return {
  font = wezterm.font("Liga SFMonoNerdFont"),
  font_size = 10,
  color_scheme = "Oxocarbon Dark (Gogh)",

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

  window_background_opacity = 0.87,
  macos_window_background_blur = 20,

  enable_scroll_bar = false,
  native_macos_fullscreen_mode = true,

  default_prog = target_shell,

  -- default_cwd = wezterm.home_dir,
  adjust_window_size_when_changing_font_size = false,

  exit_behavior = "Close",
  window_close_confirmation = "NeverPrompt"
}
