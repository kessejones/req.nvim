local Request = require('req.libs.Request')
local expander = require('req.parser.expander')
local ts = vim.treesitter

local query = vim.treesitter.query.parse(
    "http",
    [[
(section
    (variable_declaration
        name: (_) @name
        value: (_) @value)*
    request: (_) @request) @section
]]
)

---@class req.Parser
---@field bufnr integer
---@field tree vim.treesitter.dev.TSTreeView
---@field requests table<req.Request>
---@field variables req.Variables
local Parser = {}

---@param bufnr integer
---@param envs req.Variables
function Parser.new(bufnr, envs)
    ---@diagnostic disable-next-line
    local ts_parser, err = vim.treesitter.get_parser(bufnr, 'http')
    assert(not err)
    ---@diagnostic disable-next-line
    local tree = ts_parser:parse(false)[1]

    return setmetatable({
        bufnr = bufnr,
        tree = tree,
        requests = {},
        variables = envs or {},
    }, { __index = Parser })
end

---@param node TSNode
function Parser:parse_variable(node)
    local name = ts.get_node_text(node:field('name')[1], self.bufnr)
    local value = ts.get_node_text(node:field('value')[1], self.bufnr)

    self.variables[name] = expander.expand_all(value, self.variables)
    return name, value
end

---@param node TSNode
function Parser:parse_request(node)
    local variables = self.variables
    self.variables = {}

    local request = Request.new()

    local method = ts.get_node_text(node:field('method')[1], self.bufnr)
    local url = ts.get_node_text(node:field('url')[1], self.bufnr)

    request:set_method(method)
    request:set_url(expander.expand_all(url, variables))

    local node_headers = node:field('header')

    for _, h in ipairs(node_headers) do
        local key = ts.get_node_text(h:field('name')[1], self.bufnr)
        local value = ts.get_node_text(h:field('value')[1], self.bufnr)

        request:set_header(
            expander.expand_all(key, variables),
            expander.expand_all(value, variables)
        )
    end

    local node_body = node:field('body')[1]
    if node_body then
        local node_path = node_body:field('path')[1]
        if node_path then
            local path = ts.get_node_text(node_path, self.bufnr)
            if vim.fn.isabsolutepath(path) == 0 then
                -- TODO: Handle if buffer path is not a valid path
                local buf_path = vim.fs.dirname(vim.api.nvim_buf_get_name(self.bufnr))
                path = vim.fs.normalize(vim.fs.joinpath(buf_path, path))
            end
            request:set_file(path)
        else
            local body = ts.get_node_text(node_body, self.bufnr)
            request:set_body(expander.expand_all(body, variables))
        end
    end

    table.insert(self.requests, request)
end

---@param node TSNode
function Parser:parse_section(node)
    for child, _ in node:iter_children() do
        if child:type() == 'variable_declaration' then
            self:parse_variable(child)
        end

        if child:type() == 'request' then
            self:parse_request(child)
        end
    end
end

function Parser:parse_entire_buffer()
    ---@diagnostic disable-next-line
    for id, node, _metadata, _match in query:iter_captures(self.tree:root(), self.bufnr) do
        -- TODO: parse request name
        if node:type() == 'section' then
            self:parse_section(node)
        end
    end
end

---@param cursor table<integer>?
---@return req.Request
function Parser:parse(cursor)
    if cursor then
        local node = vim.treesitter.get_node({
          bufnr = self.bufnr,
          pos = { cursor[1] - 1, cursor[2] },
        })

        while node and node:type() ~= 'section' do
            node = node:parent()
        end

        if node then
            self:parse_section(node)
        else
            -- TODO: Should it be the fallback or just do nothing
            self:parse_entire_buffer()
        end
    else
        self:parse_entire_buffer()
    end

    return self.requests
end

return Parser
