local M = {}

---@return integer
function M.create()
    local buf = vim.api.nvim_create_buf(false, false)

    vim.api.nvim_create_autocmd('BufEnter', {
        buf = buf,
        callback = function ()
            vim.opt_local.wrap = false
        end
    })

    return buf
end

---@param bufnr integer
function M.split_buffer(bufnr)
    vim.cmd('rightbelow vertical sbuffer ' .. bufnr)
end


return M
