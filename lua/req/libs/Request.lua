---@enum (key) Method 
local Method = {
    GET = 1,
    POST = 2,
    PUT = 3,
    PATCH = 4,
    DELETE = 5,
}

---@class Request
---@field method Method
---@field url string
---@field version string
---@field query table<string, string>
---@field headers table<string, string>
---@field data table<string, string>
local Request = {}

---@param method Method?
---@param url string?
---@param version string?
---@param headers table<string, string>?
---@param body string?
function Request.new(method, url, version, headers, body, variables)
    return setmetatable({
        method = method or nil,
        url = url or nil,
        version = version or nil,
        query = {},
        headers = headers or {},
        variables = variables or {},
        data = {
            body = body
        },
    }, { __index = Request })
end

---@param variables Variables
function Request:setVariables(variables)
    self.variables = variables
end

---@param url string
function Request:setUrl(url)
    self.url = url
end

---@param version string
function Request:setVersion(version)
    self.version = version
end

---@param method Method
function Request:setMethod(method)
    self.method = method
end

---@param name string
---@param value string
function Request:setHeader(name, value)
    self.headers[name] = value
end

---@param body string
function Request:setBody(body)
    self.data.body = body
end

---@param name string
---@param value string
function Request:setQuery(name, value)
    self.query[name] = value
end

return Request
