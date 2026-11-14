
---@class Curl
---@field request Request
---@field buffer table<string>
local Curl = {}

function Curl.new(request)
    return setmetatable({
        request = request,
    }, { __index = Curl })
end

---@param request Request
function Curl:build()
    local command = {}
    table.insert(command, 'curl')

    table.insert(command, '-X')
    table.insert(command, self.request.method)

    for name, value in pairs(self.request.headers) do
        table.insert(command, '-H')
        table.insert(command, string.format("'%s: %s'", name, value))
    end

    -- TODO: insert body for post/put/patch
    --       use correctly the data type from the content-type header

    table.insert(command, self.request.url)
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
