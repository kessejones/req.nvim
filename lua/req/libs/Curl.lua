local helper = require('req.parser.helper')

---@param method req.Method
---@return boolean
local function is_method_valid_for_body(method)
    return method == 'POST' or method == "PUT" or method == "PATCH"
end

---@param header string
---@return boolean
local function is_header_user_agent(header)
    return header:lower() == 'user-agent'
end

---@class req.Curl
---@field request req.Request
---@field buffer table<string>
local Curl = {}

function Curl.new(request)
    return setmetatable({
        request = request,
    }, { __index = Curl })
end

---@return table<string>
function Curl:build()
    local command = {}

    table.insert(command, 'curl')
    table.insert(command, '-w')
    table.insert(command, '\n\ntime_total=%{time_total} size_download=%{size_download}')

    table.insert(command, '-X')
    table.insert(command, self.request.method)

    local has_user_agent = false
    for name, value in pairs(self.request.headers) do
        table.insert(command, '-H')
        table.insert(command, string.format("%s: %s", name, value))

        if is_header_user_agent(name) then
            has_user_agent = true
        end
    end

    if not has_user_agent then
        table.insert(command, '--user-agent')
        table.insert(command, 'req')
    end

    if is_method_valid_for_body(self.request.method) then
        if self.request.body_type == "BODY" then
            table.insert(command, '--data-raw')
            table.insert(command, self.request.data.body)
        elseif self.request.body_type == "FILE" then
            table.insert(command, '--data')
            table.insert(command, '@' .. self.request.data.file)
        end
    end

    table.insert(command, helper.encode_query_parameters(self.request.url))
    table.insert(command, '-s')
    table.insert(command, '-D')
    table.insert(command, '-')

    return command
end

---@return string
function Curl:toString()
    local command = self:build()
    return table.concat(command, ' ')
end

return Curl
