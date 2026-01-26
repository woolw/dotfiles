-- Tree-sitter for syntax highlighting
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "bash",
          "c",
          "c_sharp",
          "css",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "nix",
          "odin",
          "python",
          "rust",
          "scss",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        auto_install = true,
      })
    end,
  },
}
