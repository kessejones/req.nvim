local config = require('req.config')

local M = {}

---@param input string
---@param variables table<string, string>
function M.expand_all(input, variables)
    return input:gsub("{{%s*(.-)%s*}}", function (match)
        assert(#match > 0)

        local value = variables[match]
        assert(value ~= nil, "req.nvim - undefined variable " .. match)

        -- TODO: create diagnostics

        return value
    end)
end

---@param name string
---@param value string
---@return string
function M.expand_header_interceptor(name, value)
    local func = config.config.interceptors.headers[name]
    if func then
        local result = func(value)
        if type(result) == 'string' then
            return result
        end
    end
    return value
end

return M
