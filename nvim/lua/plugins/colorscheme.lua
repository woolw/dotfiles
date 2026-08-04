-- One Dark theme
return {
  "navarasu/onedark.nvim",
  priority = 1000,
  config = function()
    require("onedark").setup({
      style = "dark",
      transparent = false,
      term_colors = true,
      -- Flatten just the editor background to pure black for OLED, same
      -- approach as BreezeDarkOled.colors — leave the rest of the palette
      -- (floats, statusline, syntax colors) untouched.
      colors = {
        bg0 = "#000000",
      },
      code_style = {
        comments = "italic",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },
      lualine = {
        transparent = false,
      },
      diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
      },
    })
    require("onedark").load()
  end,
}
