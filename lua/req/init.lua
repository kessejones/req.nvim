local config = require('req.config')
local parser = require('req.parser')
local requester = require('req.requester')
local view = require('req.view')

local M = {}

function M.setup(opts)
    config.setup(opts)

    vim.treesitter.language.register('req_result', 'req_result')
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {'req_result'},
        callback = function()
            vim.treesitter.start()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo.foldmethod = "indent"
            vim.wo.foldlevel = 99
            vim.wo.foldenable = true
            vim.wo.foldcolumn = "0"
        end,
    })
end

function M.run(opts)
    opts = opts or {}

    -- TODO: Run on the request under the cursor

    local bufnr = vim.api.nvim_get_current_buf()
    local requests = parser.parse(bufnr)

    requester.fire(requests[1], function (result)
        view.show(result)
    end)
end

return M
