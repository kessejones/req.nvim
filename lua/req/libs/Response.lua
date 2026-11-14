local helper = require('req.parser.helper')

---@class req.Response
---@field status integer
---@field http_version string
---@field headers req.Headers
---@field content string
---@field max_header_name integer
---@field time_total number
---@field size_download number
local Response = {}

---@param status integer
---@param version string
---@param headers req.Headers
---@param content string?
---@param max_header_name integer?
---@param time_total number?
---@param size_download number?
function Response.new(status, version, headers, content, max_header_name, time_total, size_download)
    return setmetatable({
        status = status or 0,
        http_version = version or nil,
        headers = headers or {},
        content = content or nil,
        max_header_name = max_header_name or 0,
        time_total = time_total or 0,
        size_download = size_download or 0,
    }, { __index = Response })
end

---@param name string
---@return string?
function Response:header(name)
    return self.headers[string.lower(name)]
end

---@return string?
function Response:content_type()
    return self:header('content-type')
end

---@param output string
---@return req.Response
function Response.from_curl_output(output)
    local lines = vim.split(output, '\n')
    local status_line = helper.parse_status_line(lines[1])

    local headers = {}
    local content_start_line = 0
    local max_header_name = 0
    for i = 2, #lines do
        if #vim.trim(lines[i]) == 0 then
            content_start_line = i + 1
            break
        end

        local header = helper.parse_header_line(lines[i])
        local name = string.lower(header[1])
        headers[name] = header[2]

        if #name > max_header_name then
            max_header_name = #name
        end
    end

    local buffer = {}
    -- NOTE: There're two empty lines as separator
    --       Last line is a reserved line for the statistics
    for i = content_start_line, #lines - 2 do
        table.insert(buffer, lines[i])
    end

    local content = table.concat(buffer, '')
    local time_total, size_downloaded = helper.parse_response_statistics(lines[#lines])

    return Response.new(
        status_line[2],
        status_line[1],
        headers,
        content,
        max_header_name,
        time_total,
        size_downloaded
    )
end

return Response
