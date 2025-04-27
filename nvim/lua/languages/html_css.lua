local lspconfig = require("lspconfig")
local on_attach = require("languages.utils.lsp_on_attach").on_attach

lspconfig.html.setup({
  on_attach = on_attach
})

lspconfig.cssls.setup({
  on_attach = on_attach
})
