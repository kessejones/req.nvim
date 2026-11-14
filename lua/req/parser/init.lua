local ParserTreesitter = require('req.parser.ParserTreesitter')
local ts = vim.treesitter

local REQUEST_QUERY = vim.treesitter.query.parse(
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

local M = {}

---@param bufnr integer
---@return Request
function M.parse(bufnr)
    -- return Parser.new(lines):parse()
    return ParserTreesitter.new(bufnr):parse()
end

return M
