local Request = require('req.libs.Request')
local expander = require('req.parser.expander')
local ts = vim.treesitter

local query = vim.treesitter.query.parse(
    "http",
    [[
(section
    (request_separator
        value: (_) @name)
    request: (_)) @request
(section
    (comment
        name: (_) @_keyword
        value: (_) @name
        (#eq? @_keyword "name"))
    request: (_)) @request
]]
)

---@class Parser
---@field bufnr integer
---@field tree vim.treesitter.dev.TSTreeView
---@field requests table<Request>
local Parser = {}

---@param bufnr integer
function Parser.new(bufnr)
    ---@diagnostic disable-next-line
    local ts_parser, err = vim.treesitter.get_parser(bufnr, 'http')
    assert(not err)
    ---@diagnostic disable-next-line
    local tree = ts_parser:parse(false)[1]

    return setmetatable({
        bufnr = bufnr,
        tree = tree,
        requests = {},
    }, { __index = Parser })
end

---@param node TSNode
function Parser:parse_variable(node)
    local name = ts.get_node_text(node:field('name')[1], self.bufnr)
    local value = ts.get_node_text(node:field('value')[1], self.bufnr)

    return name, value
end

---@param node TSNode
---@param variables Variables
function Parser:parse_request(node, variables)
    local request = Request.new()

    local method = ts.get_node_text(node:field('method')[1], self.bufnr)
    local url = ts.get_node_text(node:field('url')[1], self.bufnr)

    request:setMethod(method)
    request:setUrl(expander.expand_all(url, variables))

    local node_headers = node:field('header')

    for _, h in ipairs(node_headers) do
        local key = ts.get_node_text(h:field('name')[1], self.bufnr)
        local value = ts.get_node_text(h:field('value')[1], self.bufnr)

        request:setHeader(
            expander.expand_all(key, variables),
            expander.expand_all(value, variables)
        )
    end

    local node_body = node:field('body')
    if #node_body > 0 then
        local body = ts.get_node_text(node_body[1], self.bufnr)
        request:setBody(expander.expand_all(body, variables))
    end

    table.insert(self.requests, request)
end

---@param node TSNode
function Parser:parse_section(node)
    local variables = {}
    for i = 1, node:child_count() do
        local child = node:child(i)
        if child then
            if child:type() == 'variable_declaration' then
                local name, value = self:parse_variable(child)
                variables[name] = value
            end

            if child:type() == 'request' then
                self:parse_request(child, variables)
                variables = {}
            end
        end
    end
end

---@return Request
function Parser:parse()
    ---@diagnostic disable-next-line
    for id, node, _metadata, _match in query:iter_captures(self.tree:root(), self.bufnr) do
        -- local capture_name = query.captures[id]

        -- TODO: parse request name
        if node:type() == 'section' then
            self:parse_section(node)
        end
    end

    return self.requests
end

return Parser
