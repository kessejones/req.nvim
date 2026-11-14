local default_configs = {
    formatters = {
        json = { 'jq', '-M' }
    }
}

local M = {}

function M.setup(opts)
    opts = opts or {}

    M.config = vim.tbl_extend('force', default_configs, opts)
end

function M.formatters()
    return M.config.formatters
end

return M
