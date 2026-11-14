local helper = require('req.parser.helper')

---@class Response
---@field status integer
---@field http_version string
---@field headers table<string, string>
---@field content string
---@field max_header_name integer
local Response = {}

---@alias Headers table<string, string>
---@alias Header table<string>

---@param status integer
---@param version string
---@param headers Headers
---@param content string?
---@param max_header_name integer?
function Response.new(status, version, headers, content, max_header_name)
    return setmetatable({
        status = status or 0,
        http_version = version or nil,
        headers = headers or {},
        content = content or nil,
        max_header_name = max_header_name or 0,
    }, {__index = Response})
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
---@return Response
function Response.from_curl_output(output)
    local lines = vim.split(output, '\n')
    local statusLine = helper.parseStatusLine(lines[1])

    local headers = {}
    local content_start_line = 0
    local max_header_name = 0
    for i = 2, #lines do
        if #vim.trim(lines[i]) == 0 then
            content_start_line = i + 1
            break
        end

        local header = helper.parseHeaderLine(lines[i])
        local name = string.lower(header[1])
        headers[name] = header[2]

        if #name > max_header_name then
            max_header_name = #name
        end
    end

    local buffer = {}
    for i = content_start_line, #lines do
        table.insert(buffer, lines[i])
    end

    local content = table.concat(buffer, '')

    return Response.new(statusLine[2], statusLine[1], headers, content, max_header_name)
end

return Response
