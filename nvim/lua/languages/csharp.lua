local lspconfig = require("lspconfig")
lspconfig.omnisharp.setup({
    cmd = { "omnisharp" },
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
        })
    end,
    enable_import_completion = true,
    organize_imports_on_format = true,
    enable_roslyn_analyzers = true,
})
