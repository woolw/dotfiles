return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "go", "lua", "odin", "c_sharp", "rust", "sql",
          "typescript", "tsx", "javascript",
          "html", "css", "json", "yaml", "markdown", "bash"
        },
        highlight = { enable = true },
        indent = {enable= true}
      })
    end
  },
}
