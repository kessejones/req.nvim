local Parser = require('req.parser.Parser')
local dotenv = require('req.parser.dotenv')

local M = {}

---@param bufnr integer
---@param envs req.Variables
---@return req.Request
function M.parse(bufnr, envs)
    return Parser.new(bufnr, envs):parse()
end

---@param env_file string
---@return req.Variables
function M.parse_env_file(env_file)
    return dotenv.parse(env_file)
end

return M
