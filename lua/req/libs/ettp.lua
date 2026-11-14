local M = {}

local status_code = {
    [200] = "Ok",
    [201] = "Created",
    [204] = "No Content",
    [404] = "Not Found",
    [500] = "Internal Error",
    [503] = "Bad Gateway",
}

---@param code integer
---@return string
function M.status(code)
    return status_code[code] or ''
end

return M
