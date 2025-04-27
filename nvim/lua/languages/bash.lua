local lspconfig = require("lspconfig")

lspconfig.bashls.setup({
  on_attach = require("languages.utils.lsp_on_attach").on_attach,
})
