local config = require('req.config')
local helper = require('req.helper')

local M = {}

---@param type string
---@return boolean
function M.has_type(type)
    local cmd = config.formatters()[type]
    if cmd then
        return true
    end

    return false
end

---@param type string
---@param source string
---@return string?
function M.format(type, source)
    local cmd = config.formatters()[type]
    if cmd then
        return helper.exec(cmd, source)
    end
    return nil
end

return M
