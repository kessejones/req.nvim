local M = {}

---@class req.Config
---@field formatters req.Formatters
---@field interceptors req.Interceptors
local default_configs = {
    formatters = {
        json = { 'jq', '-M' },
        html = { 'prettier', '--parser', 'html' }
    },
    interceptors = {
        headers = {
            Authorization = function (value)
                local matches = value:gmatch('Basic%s+(.+):(.+)$')
                local user, pass = matches()
                if user and pass then
                    return 'Basic ' .. vim.base64.encode(user .. ':' .. pass)
                end

                return false
            end,
        },
    },
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
