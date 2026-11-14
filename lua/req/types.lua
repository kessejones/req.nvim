---@alias req.Formatter table<string>

---@alias req.Formatters table<string, req.Formatter>

---@alias req.Variables table<string, string>

---@alias req.Method "POST" | "GET" | "PUT" | "DELETE" | "PATCH"

---@class req.Header table<string, string>

---@class req.Headers table<string, string>

---@class req.ContentRange
---@field row_start integer
---@field row_end integer

---@alias req.RequestBodyType "FILE" | "BODY"

---@class req.RequestData
---@field body string?
---@field file string?

---@alias req.RequestLine table<string>
