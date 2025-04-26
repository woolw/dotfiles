require("core.basic")
require("core.lazy")

require("lazy").setup({
  { import = "plugins.ui" },
  { import = "plugins.treesitter" },
  { import = "plugins.lsp" },
  { import = "plugins.formatter" },
})
