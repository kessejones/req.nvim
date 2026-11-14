local M = {}

---@alias RequestLine table<string>

---@param line string
---@return Header
function M.parseHeaderLine(line)
    local pos = line:find(':')

    local name = vim.trim(line:sub(1, pos-1))
    local value = vim.trim(line:sub(pos+1, #line))
    return { name, value }
end

---@param line string
---@return RequestLine
function M.parseRequestLine(line)
    local parts = vim.split(line, ' ')

    local method = vim.trim(parts[1])
    local url = vim.trim(parts[2])

    local version
    if #parts == 3 then
        version = vim.trim(parts[3])
    end

    return { method, url, version }
end

---@param line string
---@return RequestLine
function M.parseStatusLine(line)
    local lineParts = vim.split(line, ' ')

    local version = lineParts[1]
    local status = lineParts[2]

    return { version, tonumber(status) }
end

return M
