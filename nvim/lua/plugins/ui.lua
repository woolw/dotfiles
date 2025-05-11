return {
    {
        "shaunsingh/nord.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme nord")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "nord",
                    section_separators = "",
                    component_separators = "",
                }
            })
        end
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup()
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
        end
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-media-files.nvim",
        },
        build = "make",
        keys = {
            { "<leader>tt", function() require("telescope.builtin").find_files() end,                 desc = "Find Files" },
            { "<leader>tg", function() require("telescope.builtin").live_grep() end,                  desc = "Live Grep" },
            { "<leader>tb", function() require("telescope.builtin").buffers() end,                    desc = "Find Buffers" },
            { "<leader>th", function() require("telescope.builtin").help_tags() end,                  desc = "Help Tags" },
            { "<leader>tr", function() require("telescope.builtin").oldfiles() end,                   desc = "Recent Files" },
            { "<leader>ts", function() require("telescope.builtin").current_buffer_fuzzy_find() end,  desc = "Search in Buffer" },

            { "<leader>tm", function() require("telescope").extensions.media_files.media_files() end, desc = "Media Files" },
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    prompt_prefix = "   ",
                    selection_caret = " ",
                    entry_prefix = "  ",
                    initial_mode = "insert",
                    selection_strategy = "reset",
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.8,
                        },
                        vertical = { mirror = false },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },
                    winblend = 10,
                    border = true,
                    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                    path_display = { "truncate" },
                    mappings = {
                        i = {
                            ["<esc>"] = actions.close,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                        },
                    },
                },
                extensions = {
                    media_files = {
                        filetypes = { "png", "jpg", "mp4", "webm", "pdf" },
                        find_cmd = "rg",
                    },
                },
            })

            telescope.load_extension("media_files")
        end,
    },
    {
        "echasnovski/mini.nvim",
        version = "*",
        config = function()
            -- optional: you can configure only what you use, like mini.icons
            require('mini.icons').setup()
        end
    },
    {
        "folke/which-key.nvim",
        config = function()
            local wk = require("which-key")
            wk.setup({
                plugins = {
                    spelling = { enabled = true },
                },
                layout = {
                    align = "center",
                },
            })

            wk.add({
                { "<leader>u", group = "UI" },
                { "<leader>d", group = "Debug" },
                { "<leader>t", group = "Telescope" },
            })
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "│" }, -- or "▏" for thinner
            scope = { enabled = false },
            whitespace = { highlight = { "Whitespace" } },
            exclude = {
                filetypes = { "help", "terminal", "lazy", "dashboard", "nofile" },
            },
        },
    }
}
