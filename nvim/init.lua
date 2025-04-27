require("core.basic")
require("core.lazy")
vim.keymap.set("n", "<leader>ut", require("core.transparent").toggle, { desc = "Toggle Transparency" })


require("lazy").setup({
  { import = "plugins.ui" },
  { import = "plugins.treesitter" },
  { import = "plugins.lsp" },
  { import = "plugins.formatter" },
  { import = "plugins.debugger" },
})
