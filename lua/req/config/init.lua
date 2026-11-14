local M = {}

---@class req.Config
---@field formatters req.Formatters
local default_configs = {
    formatters = {
        json = { 'jq', '-M' },
        html = { 'prettier', '--parser', 'html' }
    }
}

---@param opts req.Config
function M.setup(opts)
    opts = opts or {}

    M.config = vim.tbl_extend('force', default_configs, opts)
end

---@return req.Formatters
function M.formatters()
    return M.config.formatters
end

return M
