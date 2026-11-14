local M = {}

---@param line string
---@return req.Header
function M.parse_header_line(line)
    local pos = line:find(':')

    local name = vim.trim(line:sub(1, pos-1))
    local value = vim.trim(line:sub(pos+1, #line))
    return { name, value }
end

---@param line string
---@return req.RequestLine
function M.parse_request_line(line)
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
---@return req.RequestLine
function M.parse_status_line(line)
    local lineParts = vim.split(line, ' ')

    local version = lineParts[1]
    local status = lineParts[2]

    return { version, tonumber(status) }
end

---@param line string
---@return number, number
function M.parse_response_statistics(line)
    local matches = line:gmatch('time_total=(%d+%.%d+) size_download=(%d+%.?%d*)')
    local time_total, size_downloaded = matches()
    if time_total then
        return tonumber(time_total) or 0, tonumber(size_downloaded) or 0
    end

    return 0, 0
end

return M
