return {
    { "williamboman/mason.nvim", config = true },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "rust_analyzer",
                    "gopls",
                    "lua_ls",
                    "ols",
                    "omnisharp",
                    "ts_ls",
                    "html",
                    "cssls",
                    "sqlls",
                    "bashls",
                }
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("languages.rust")
            require("languages.go")
            require("languages.lua_ls")
            require("languages.typescript")
            require("languages.csharp")
            require("languages.sql")
            require("languages.html_css")
            require("languages.bash")
        end
    },
}
