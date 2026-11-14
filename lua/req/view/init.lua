local helper = require('req.helper')
local View = require('req.view.View')

local M = {}

local __buf_cache = {}
local __req_history = {}

---@return integer
local function create_buffer()
    local buf = vim.api.nvim_create_buf(false, false)
    vim.bo[buf].filetype = 'req_result'
    vim.bo[buf].buftype = 'nofile'

    vim.api.nvim_create_autocmd('BufEnter', {
        buf = buf,
        callback = function ()
            vim.opt_local.wrap = false
        end
    })

    return buf
end

---@param buf integer
local function split_buffer(buf)
    vim.cmd('rightbelow vertical sbuffer ' .. buf)
end

---@param buf integer
---@param result req.Result
local view_result = vim.schedule_wrap(function(buf, result)
    local view = View.new(buf, result)
    view:update()
    view:render()

    if not helper.is_buffer_visible(buf) then
        split_buffer(buf)
    end
end)

---@param tab integer
---@return integer
local function get_or_create_buffer(tab)
    local buf = __buf_cache[tab]

    if buf == nil then
        buf = create_buffer()
        __buf_cache[tab] = buf
    end

    return buf
end

---@param result req.Result
function M.show(result)
    local tab = vim.api.nvim_get_current_tabpage()
    local buf = get_or_create_buffer(tab)

    __req_history[tab] = result
    view_result(buf, result)
end

function M.view_last_from_history()
    local tab = vim.api.nvim_get_current_tabpage()
    local buf = get_or_create_buffer(tab)

    local result = __req_history[tab]
    if result then
        view_result(buf, result)
    end
end

function M.setup()
    -- NOTE: cleanup the buffer associated with the tab
    vim.api.nvim_create_autocmd('TabClosed', {
        callback = function()
            local tabs = vim.api.nvim_list_tabpages()
            for tab, buf in ipairs(__buf_cache) do
                if not vim.tbl_contains(tabs, tab) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                    __req_history[tab] = nil
                    break
                end
            end
        end
    })
end

return M
