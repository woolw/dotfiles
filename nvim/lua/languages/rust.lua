local lspconfig = require("lspconfig")
local on_attach = require("languages.utils.lsp_on_attach").on_attach

lspconfig.rust_analyzer.setup({
    on_attach = on_attach
})
