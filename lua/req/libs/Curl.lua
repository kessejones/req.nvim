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
    table.insert(command, '"\n\ntime_total=%{time_total} size_download=%{size_download}"')

    table.insert(command, '-X')
    table.insert(command, self.request.method)

    for name, value in pairs(self.request.headers) do
        table.insert(command, '-H')
        table.insert(command, string.format("'%s: %s'", name, value))
    end

    -- TODO: insert body for post/put/patch
    --       use correctly the data type from the content-type header

    if self.request.body_type == "BODY" then
        table.insert(command, '--data-raw')
        table.insert(command, self.request.data.body)
    elseif self.request.body_type == "FILE" then
        table.insert(command, '--data')
        table.insert(command, '@' .. self.request.data.file)
    end

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
