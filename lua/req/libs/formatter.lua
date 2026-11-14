local config = require('req.config')

local M = {}

---@param command table
---@param source string
---@return string
local function exec(command, source)
    local task = vim.system(
        command,
        { text = true, stdin = true }
    )

    task:write(source)
    task:write(nil)

    local result = task:wait()

    return result.stdout
end

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
        return exec(cmd, source)
    end
    return nil
end

return M
