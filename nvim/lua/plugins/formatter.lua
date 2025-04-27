return {
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.csharpier,
          null_ls.builtins.formatting.shfmt,
          null_ls.builtins.diagnostics.shellcheck,
        },
      })
    end
  },
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = {
          "prettier",
          "csharpier",
          "shfmt",
          "shellcheck",
        },
        automatic_installation = true,
      })
    end
  },
}
