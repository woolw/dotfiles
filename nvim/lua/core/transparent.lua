local M = {}

local transparent = false

function M.toggle()
    transparent = not transparent

    if transparent then
        vim.cmd([[
            highlight Normal guibg=NONE ctermbg=NONE
            highlight NormalNC guibg=NONE ctermbg=NONE
            highlight SignColumn guibg=NONE ctermbg=NONE
            highlight VertSplit guibg=NONE ctermbg=NONE
            highlight StatusLine guibg=NONE ctermbg=NONE
            highlight LineNr guibg=NONE ctermbg=NONE
            highlight CursorLineNr guibg=NONE ctermbg=NONE
            highlight Pmenu guibg=NONE ctermbg=NONE
            highlight PmenuSel guibg=NONE ctermbg=NONE
            highlight FloatBorder guibg=NONE ctermbg=NONE
            highlight NormalFloat guibg=NONE ctermbg=NONE
        ]])
        vim.notify("Transparency Enabled", vim.log.levels.INFO)
    else
        -- Reset to original background color (optional: tweak depending on your theme)
        vim.cmd([[
            highlight Normal guibg=#161616
            highlight NormalNC guibg=#161616
            highlight SignColumn guibg=#161616
            highlight VertSplit guibg=#161616
            highlight StatusLine guibg=#161616
            highlight LineNr guibg=#161616
            highlight CursorLineNr guibg=#161616
            highlight Pmenu guibg=#202020
            highlight PmenuSel guibg=#353535
            highlight FloatBorder guibg=#202020
            highlight NormalFloat guibg=#202020
        ]])
        vim.notify("Transparency Disabled", vim.log.levels.INFO)
    end
end

return M
