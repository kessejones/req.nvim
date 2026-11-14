local config = require('req.config')
local parser = require('req.parser')
local requester = require('req.requester')
local view = require('req.view')
local helper = require('req.helper')

local M = {}

local function create_commands()
    vim.api.nvim_create_user_command('ReqRun', function (_args)
        M.run({ under_cursor = true })
    end, {})

    vim.api.nvim_create_user_command('ReqViewLast', function (_args)
        M.view_last()
    end, {})
end

---@param opts req.Config
function M.setup(opts)
    config.setup(opts)
    view.setup()
    create_commands()
end

---@param opts req.RunOptions
function M.run(opts)
    opts = opts or {}

    local cursor
    if opts.under_cursor then
        cursor = vim.api.nvim_win_get_cursor(0)
    end

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

        local requests = parser.parse(cursor, buf, envs)
        requester.fire(requests[1], function (result)
            view.show(result)
        end)
    else
        vim.notify('req.nvim - only http files are allowed for requests', vim.log.levels.WARN)
    end
end

function M.view_last()
    view.view_last_from_history()
end

return M
