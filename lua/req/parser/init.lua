local Parser = require('req.parser.Parser')

local M = {}

---@param bufnr integer
---@return req.Request
function M.parse(bufnr)
    return Parser.new(bufnr):parse()
end

return M
