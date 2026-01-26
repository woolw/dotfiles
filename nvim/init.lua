-- Compatibility shim for deprecated treesitter functions (Neovim 0.11+)
-- Must be before any plugins load
if vim.treesitter.language.get_lang and not vim.treesitter.language.ft_to_lang then
  vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
end

-- Bootstrap lazy.nvim and load config
require("config.options")
require("config.lazy")
require("config.keymaps")
