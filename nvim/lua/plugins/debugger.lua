return {
    "mfussenegger/nvim-dap",
    dependencies = {
        { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup()

        dap.adapters.coreclr = {
            type = 'executable',
            command = '/usr/bin/netcoredbg',
            args = { '--interpreter=vscode' }
        }

        dap.configurations.cs = {
            {
                type = "coreclr",
                name = "launch - netcoredbg",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/', 'file')
                end,
            },
        }

        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        -- Debug keybinds
        vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "Start/Continue Debugging" })
        vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "Step Over" })
        vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "Step Into" })
        vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "Step Out" })
        vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>dB", function()
            dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end, { desc = "Set Conditional Breakpoint" })
        vim.keymap.set("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "Toggle REPL" })
        vim.keymap.set("n", "<leader>dl", function() dap.run_last() end, { desc = "Run Last Debug Session" })
    end
}
