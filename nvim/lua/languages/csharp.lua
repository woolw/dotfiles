local lspconfig = require("lspconfig")
local on_attach = require("languages.utils.lsp_on_attach").on_attach

lspconfig.omnisharp.setup({
    cmd = { "omnisharp" },
    on_attach = on_attach,
    enable_import_completion = true,
    organize_imports_on_format = true,
    enable_roslyn_analyzers = true,
})
