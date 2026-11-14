---@class req.Request
---@field method req.Method
---@field url string
---@field version string
---@field query table<string, string>
---@field headers table<string, string>
---@field body_type req.RequestBodyType
---@field data req.RequestData
local Request = {}

---@return req.Request
function Request.new()
    return setmetatable({
        method = nil,
        url = nil,
        version = nil,
        headers = {},
        variables = {},
        body_type = nil,
        data = {
            query = nil, -- TODO: unused for now, maybe remove and use only parameter set in url
            body = nil,
            file = nil,
        },
    }, { __index = Request })
end

---@param variables req.Variables
function Request:set_variables(variables)
    self.variables = variables
end

---@param url string
function Request:set_url(url)
    self.url = url
end

---@param version string
function Request:set_version(version)
    self.version = version
end

---@param method req.Method
function Request:set_method(method)
    self.method = method
end

---@param name string
---@param value string
function Request:set_header(name, value)
    self.headers[name] = value
end

---@param body string
function Request:set_body(body)
    self.body_type = "BODY"
    self.data.body = body
end

---@param file string
function Request:set_file(file)
    self.body_type = "FILE"
    self.data.file = file
end

---@param name string
---@param value string
function Request:set_query(name, value)
    self.query[name] = value
end

return Request
