local helper = require('req.helper')
local buffer = require('req.view.buffer')
local View = require('req.view.View')

local M = {}

local __buf_cache = {}

---@param bufnr integer
---@param result req.Result
local function show_internal(bufnr, result)
    local view = View.new(bufnr, result)
    view:update()
    view:render()

    if not helper.is_buffer_visible(bufnr) then
        buffer.split_buffer(bufnr)
    end
end

---@param tabnr integer
---@return integer
local function get_or_create_buffer(tabnr)
    local bufnr = __buf_cache[tabnr]

    if bufnr == nil then
        bufnr = buffer.create()
        __buf_cache[tabnr] = bufnr
    end

    return bufnr
end

---@param result req.Result
function M.show(result)
    local tabnr = vim.api.nvim_get_current_tabpage()
    local bufnr = get_or_create_buffer(tabnr)

    vim.schedule(function ()
        show_internal(bufnr, result)
    end)
end

return M
