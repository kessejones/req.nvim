local config = require('req.config')
local parser = require('req.parser')
local requester = require('req.requester')
local view = require('req.view')
local helper = require('req.helper')

local M = {}

---@param opts req.Config
function M.setup(opts)
    config.setup(opts)
end

function M.run()
    -- TODO: Run on the request under the cursor

    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    if vim.bo[buf].filetype == 'http' then
        local env_file = helper.search_dotenv_buffer_path(buf)

        local envs = {}
        if env_file then
            envs = parser.parse_env_file(env_file)
        end

        local requests = parser.parse(buf, envs)
        requester.fire(requests[1], function (result)
            view.show(result)
        end)
    else
        vim.notify('req.nvim - only http files are allowed for requests', vim.log.levels.WARN)
    end
end

return M
