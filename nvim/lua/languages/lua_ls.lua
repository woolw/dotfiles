local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    }
  }
})
