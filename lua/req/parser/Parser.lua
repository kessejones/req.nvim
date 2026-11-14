local Request = require('req.libs.Request')
-- local Builder = require('req.parser.Builder')
local expander = require('req.parser.expander')
local helper = require('req.parser.helper')

---@enum ParseMode
local ParseMode = {
    PRE_REQUEST = 0,
    URL = 2,
    HEADER = 3,
    BODY = 4,
    END = 5
}

local function isVariable(line)
    return vim.startswith(line, '@')
end

local function isRequest(line)
    return line:match('^[GET|POST|PUT|DELETE|PATCH]')
end

---@class Parser
---@field request Request
---@field lines string
---@field col integer
---@field row integer
---@field variables Variables
---@field mode ParseMode
local Parser = {}

---@param lines string[]
---@return Parser
function Parser.new(lines)
    local request = Request.new()
    return setmetatable({
        request = request,
        lines = lines,
        col = 1,
        row = 1,
        variables = {},
        mode = ParseMode.PRE_REQUEST,
    }, { __index = Parser })
end


---@return string
function Parser:line()
    return self.lines[self.row] or ""
end

---@return string
function Parser:peek()
    local line = self:line()
    return string.sub(line, 1, 1)
end

---@return boolean
function Parser:stop()
    return (self.row > #self.lines) or (self.mode == ParseMode.END)
end

function Parser:next()
    self.col = 1
    self.row = self.row + 1
end

function Parser:lineIsVariable()
    return isVariable(self:line())
end

function Parser:lineIsRequest()
    return isRequest(self:line())
end

function Parser:consume()
    if (self.col + 1) > #self.lines[self.row] then
        self:next()
    else
        self.col = (self.col + 1)
    end
end

function Parser:parseVariable()
    local line = self:line()

    local variableParts = vim.split(line, '=')
    if #variableParts == 2 then
        local name = string.sub(vim.trim(variableParts[1]), 2)
        local value = vim.trim(variableParts[2])
        self.variables[name] = value
    end
end

function Parser:preRequest()
    local char = self:peek()
    if isVariable(char) then
        self:parseVariable()
        self:next()
        return
    end

    if isRequest(self:line()) then
        self.mode = ParseMode.URL
    else
        self:next()
    end
end

function Parser:parseRequestLine()
    local line = self:line()
    local reqLine = helper.parseRequestLine(line)
    local urlResolved = expander.expand_all(reqLine[2], self.variables)

    self.request:setMethod(reqLine[1])
    self.request:setUrl(urlResolved)
    self.request:setVersion(reqLine[3])

    self.mode = ParseMode.HEADER
    self:next()
end

function Parser:parseHeaders()
    while self.mode == ParseMode.HEADER do
        local line = self:line()
        if line == "" then
            self.mode = ParseMode.BODY
            self:next()
            break
        end

        local header = helper.parseHeaderLine(line)

        self.request:setHeader(
            expander.expand_all(header[1], self.variables),
            expander.expand_all(header[2], self.variables)
        )

        self:next()
    end
end

function Parser:parseBody()
    local buffer = {}

    while self.mode == ParseMode.BODY do
        local line = self:line()

        if line == nil or #(vim.trim(line)) == 0 then
            self.mode = ParseMode.END
            break
        end

        local resolvedLine = expander.expand_all(line, self.variables)
        table.insert(buffer, resolvedLine)

        self:next()
    end

    self.request:setBody(table.concat(buffer, ''))
end

---@return Request
function Parser:parse()
    -- TODO: Add support for multiples requests in the same buffer
    --       Should it parse the `##` as title for the request?

    while not self:stop() do
        if self.mode == ParseMode.PRE_REQUEST then
            self:preRequest()
        elseif self.mode == ParseMode.URL then
            self:parseRequestLine()
        elseif self.mode == ParseMode.HEADER then
            self:parseHeaders()
        elseif self.mode == ParseMode.BODY then
            self:parseBody()
        end
    end

    return self.request
end

return Parser
