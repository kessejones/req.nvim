local M = {}

---@param path string
---@return string[]|nil
local function read_file(path)
    local fd = vim.uv.fs_open(path, "r", 644)
    if not fd then
        return nil
    end

    local stat = vim.uv.fs_fstat(fd)
    if not stat then
        return nil
    end

    local content, err = vim.uv.fs_read(fd, stat.size)
    vim.uv.fs_close(fd)

    if err or not content then
        return nil
    end


    return vim.split(content, "\n")
end

---@param path string
---@return req.Variables
function M.parse(path)
    local lines = read_file(path)
    if not lines then
        return {}
    end

    local variables = {}
    for _, line in ipairs(lines)do
        if not vim.startswith(line, "#") then
            local variable_parts = vim.split(line, '=')
            if #variable_parts == 2 then
                variables[vim.trim(variable_parts[1])] = vim.trim(variable_parts[2])
            end
        end
    end

    return variables
end

return M
